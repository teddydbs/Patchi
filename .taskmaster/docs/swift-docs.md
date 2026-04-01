# Documentation Swift — Patchi

> Référence rapide des frameworks utilisés dans le projet. Récupérée via context7 le 2026-04-01.

---

## 1. SwiftData (`@Model`, `@Query`)

**Usage :** Persistance de tous les models (User, CheckIn, Decision, AccountabilityEntry, FutureLetter)

### Définir un model

```swift
import SwiftData

@Model
class CheckIn {
    var id: UUID
    var date: Date
    var moodScore: Int
    var title: String?
    var note: String?

    init(date: Date, moodScore: Int) {
        self.id = UUID()
        self.date = date
        self.moodScore = moodScore
    }
}
```

> `@Model` ajoute automatiquement la conformité `Observable` — pas besoin de `@Observable` en plus.

### Configurer le ModelContainer

```swift
@main
struct PatchiApp: App {
    var body: some Scene {
        WindowGroup { ContentView() }
            .modelContainer(for: [
                User.self,
                CheckIn.self,
                AccountabilityEntry.self,
                Decision.self,
                FutureLetter.self
            ])
    }
}
```

### Requêter dans une vue avec @Query

```swift
struct JournalView: View {
    // Toutes les entrées triées par date décroissante
    @Query(sort: \CheckIn.date, order: .reverse) var checkIns: [CheckIn]

    var body: some View {
        List(checkIns) { checkIn in
            Text(checkIn.title ?? "Sans titre")
        }
    }
}
```

### Filtrer avec Predicate

```swift
@Query(filter: #Predicate<Decision> { $0.status == .pending })
var pendingDecisions: [Decision]
```

### Accéder au ModelContext

```swift
struct SomeView: View {
    @Environment(\.modelContext) private var modelContext

    func saveCheckIn(_ checkIn: CheckIn) {
        modelContext.insert(checkIn)
        // SwiftData sauvegarde automatiquement
    }

    func deleteCheckIn(_ checkIn: CheckIn) {
        modelContext.delete(checkIn)
    }
}
```

### Points importants

- `@Query` rafraîchit la vue automatiquement quand les données changent
- Pour CloudKit (premium) : configurer `ModelConfiguration` avec `cloudKitDatabase`
- `modelContext` accessible via `@Environment(\.modelContext)`
- `@Model` = `Observable` automatiquement — SwiftUI détecte les changements

---

## 2. SwiftUI iOS 17+ (`@Observable`, navigation, animations)

**Usage :** Toute l'UI, state management, navigation

### @Observable (remplace ObservableObject)

```swift
@Observable
class HomeViewModel {
    var currentMood: Int = 3
    var isShowingCheckIn = false
    var greeting: String = ""
}

// Dans la vue — utiliser @State (pas @StateObject)
struct HomeView: View {
    @State private var viewModel = HomeViewModel()

    var body: some View {
        Text(viewModel.greeting)
    }
}
```

> `@Observable` remplace `ObservableObject` + `@Published` depuis iOS 17.
> Plus besoin de `@ObservedObject` / `@StateObject`.

### Navigation avec @Observable

```swift
@Observable
class AppRouter {
    var path: [Route] = [] {
        didSet {
            print("Navigation changed to \(path)")
        }
    }
}

// Utilisation
NavigationStack(path: $router.path) {
    HomeView()
        .navigationDestination(for: Route.self) { route in
            // ...
        }
}
```

### Animations personnalisées (400-600ms pour Patchi)

```swift
// Transition fluide de couleur d'humeur
withAnimation(.easeInOut(duration: 0.5)) {
    currentMoodColor = Color.mood(score: newScore)
}

// Transition slide pour les vues conditionnelles
if isActive {
    PatchiView(expression: .happy)
        .transition(.slide)
}

// Animation custom avec spring
withAnimation(.spring(duration: 0.6)) {
    isExpanded.toggle()
}

// Animation élastique
withAnimation(.elasticEaseInEaseOut(duration: 0.5)) {
    patchiOffset.toggle()
}
```

### @Environment pour injecter des dépendances

```swift
// Créer une clé d'environnement
struct MoodColorKey: EnvironmentKey {
    static let defaultValue: Color = .clear
}

extension EnvironmentValues {
    var moodColor: Color {
        get { self[MoodColorKey.self] }
        set { self[MoodColorKey.self] = newValue }
    }
}

// Injecter
ContentView()
    .environment(\.moodColor, Color.mood(score: 4))

// Lire
@Environment(\.moodColor) private var moodColor
```

---

## 3. StoreKit 2 (premium ~35€/an, trial 7 jours sans CB)

**Usage :** Abonnement premium, essai 7 jours via introductoryOffer

### Charger les produits

```swift
let products = try await Product.products(for: ["com.patchi.premium.yearly"])
```

### Flow d'achat

```swift
@MainActor
func purchase(_ product: Product) async throws {
    let result = try await product.purchase()

    switch result {
    case .success(let verification):
        switch verification {
        case .verified(let transaction):
            // Activer premium
            await transaction.finish()
        case .unverified(_, let error):
            // Gérer erreur de vérification
            print("Transaction non vérifiée: \(error)")
        }
    case .userCancelled:
        break
    case .pending:
        break
    @unknown default:
        break
    }
}
```

### Vérifier les entitlements au lancement

```swift
func refreshPurchasedProducts() async {
    for await verificationResult in Transaction.currentEntitlements {
        switch verificationResult {
        case .verified(let transaction):
            // Vérifier le type de produit et activer premium
            if transaction.productID == "com.patchi.premium.yearly" {
                isPremium = true
            }
        case .unverified(_, _):
            break
        }
    }
}
```

### Écouter les mises à jour en temps réel

```swift
// À lancer au démarrage de l'app
Task {
    for await result in Transaction.updates {
        switch result {
        case .verified(let transaction):
            await transaction.finish()
            // Mettre à jour l'état premium
        case .unverified(_, _):
            break
        }
    }
}
```

### Points importants

- `introductoryOffer` : configuré dans **App Store Connect**, pas dans le code
- `Transaction.currentEntitlements` : exclut les remboursés et les consumables
- Toujours appeler `transaction.finish()` après traitement
- Tester en sandbox avec un compte Apple sandbox

---

## 4. Swift Charts (graphiques d'humeur)

**Usage :** Courbes d'humeur hebdo/mensuel, corrélations activités/humeur

### Courbe d'humeur (LineMark)

```swift
import Charts

struct MoodChartView: View {
    var weeklyMoods: [MoodEntry] // { date: Date, score: Int }

    var body: some View {
        Chart(weeklyMoods) { entry in
            LineMark(
                x: .value("Jour", entry.date),
                y: .value("Humeur", entry.score)
            )
        }
    }
}
```

### Bar chart des activités (BarMark)

```swift
Chart(activityStats, id: \.activity) { stat in
    BarMark(
        x: .value("Activité", stat.activity.displayName),
        y: .value("Fréquence", stat.count)
    )
}
```

### Aire sous la courbe (AreaMark)

```swift
Chart(monthlyMoods) { entry in
    AreaMark(
        x: .value("Date", entry.date),
        y: .value("Humeur", entry.score)
    )
    .foregroundStyle(.blue.opacity(0.3))
}
```

### Multi-séries avec ligne de référence (RuleMark)

```swift
Chart {
    ForEach(moodData, id: \.date) { item in
        LineMark(
            x: .value("Date", item.date),
            y: .value("Humeur", item.score),
            series: .value("Type", "Humeur")
        )
        .foregroundStyle(.blue)
    }

    RuleMark(y: .value("Moyenne", averageMood))
        .foregroundStyle(.orange)
        .lineStyle(StrokeStyle(dash: [5, 5]))
}
```

---

## 5. UserNotifications (5 types de notifications)

**Usage :** Notifications soir, décisions J+30/J+90, lettres 6 mois, dimanche 19h

### Demander la permission

```swift
let center = UNUserNotificationCenter.current()
do {
    try await center.requestAuthorization(options: [.alert, .sound, .badge])
} catch {
    print("Erreur permission notifications: \(error)")
}
```

### Configurer le contenu

```swift
let content = UNMutableNotificationContent()
content.title = "Patchi"
content.body = "Comment s'est passée ta journée ?"
content.sound = .default
```

### Trigger récurrent — Dimanche 19h

```swift
var dateComponents = DateComponents()
dateComponents.weekday = 1  // 1 = Dimanche
dateComponents.hour = 19
dateComponents.minute = 0

let trigger = UNCalendarNotificationTrigger(
    dateMatching: dateComponents,
    repeats: true  // Récurrent
)
```

### Trigger one-shot — J+30 pour une décision

```swift
let futureDate = Calendar.current.date(byAdding: .day, value: 30, to: decision.createdAt)!
let components = Calendar.current.dateComponents(
    [.year, .month, .day, .hour, .minute],
    from: futureDate
)
let trigger = UNCalendarNotificationTrigger(
    dateMatching: components,
    repeats: false  // Une seule fois
)
```

### Scheduler la notification

```swift
let request = UNNotificationRequest(
    identifier: "decision-\(decision.id.uuidString)-j30",
    content: content,
    trigger: trigger
)

let center = UNUserNotificationCenter.current()
do {
    try await center.add(request)
} catch {
    print("Erreur scheduling notification: \(error)")
}
```

### Supprimer une notification programmée

```swift
// Par identifiant
center.removePendingNotificationRequests(withIdentifiers: [
    "decision-\(decision.id.uuidString)-j30"
])

// Toutes les notifications en attente
center.removeAllPendingNotificationRequests()
```

### Points importants

- **Identifier unique** par notification pour pouvoir les supprimer/mettre à jour
- `repeats: true` pour récurrentes (soir, dimanche)
- `repeats: false` pour one-shot (J+30, J+90, lettres 6 mois)
- **Max 64 notifications locales** en même temps sur iOS
- Weekday : 1=Dimanche, 2=Lundi, ..., 7=Samedi

---

## 6. AuthenticationServices (Sign in with Apple)

**Usage :** Inscription et connexion via Apple ID

```swift
import AuthenticationServices

struct SignInWithAppleView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            switch result {
            case .success(let authorization):
                if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
                    let userIdentifier = credential.user
                    let email = credential.email
                    let fullName = credential.fullName
                    // Sauvegarder dans le model User
                }
            case .failure(let error):
                print("Sign in failed: \(error)")
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
    }
}
```

### Vérifier le credential au lancement

```swift
let provider = ASAuthorizationAppleIDProvider()
let state = try await provider.credentialState(forUserID: savedUserIdentifier)

switch state {
case .authorized: break    // Toujours connecté
case .revoked: break       // Déconnecté, demander reconnexion
case .notFound: break      // Pas de compte
default: break
}
```

---

## 7. SFSpeechRecognizer (entrée vocale)

**Usage :** Transcription vocale en français dans les champs texte

```swift
import Speech
import AVFoundation

class SpeechService: NSObject, ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "fr-FR"))
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    @Published var transcribedText: String = ""
    @Published var isRecording: Bool = false

    func requestPermission() async -> Bool {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        return speechStatus == .authorized
    }

    func startRecording() throws {
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
        isRecording = true

        recognitionTask = speechRecognizer?.recognitionTask(with: request) { [weak self] result, error in
            if let result = result {
                self?.transcribedText = result.bestTranscription.formattedString
            }
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        isRecording = false
    }
}
```

### Permissions nécessaires dans Info.plist

```
NSMicrophoneUsageDescription — "Patchi utilise le micro pour la saisie vocale."
NSSpeechRecognitionUsageDescription — "Patchi transcrit ta voix en texte."
```

---

## 8. LocalAuthentication (Face ID / Touch ID)

**Usage :** Verrou biométrique pour protéger l'app (premium)

```swift
import LocalAuthentication

class BiometricService {
    func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }

        do {
            return try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Déverrouille ton journal Patchi"
            )
        } catch {
            return false
        }
    }

    var biometricType: LABiometryType {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType // .faceID, .touchID, .opticID, .none
    }
}
```

### Permission dans Info.plist

```
NSFaceIDUsageDescription — "Patchi utilise Face ID pour protéger ton journal."
```

---

## 9. PhotosUI (sélection photo)

**Usage :** Photo optionnelle dans les check-ins

```swift
import PhotosUI
import SwiftUI

struct PhotoPickerView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var photoData: Data?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Label("Ajouter une photo", systemImage: "photo")
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    photoData = data
                }
            }
        }
    }
}
```

---

## 10. WidgetKit (V1.1)

**Usage :** Widget petit (heatmap 7 jours) et grand (humeur + défi)

```swift
import WidgetKit
import SwiftUI

struct HeatmapWidget: Widget {
    let kind: String = "HeatmapWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HeatmapTimelineProvider()) { entry in
            HeatmapWidgetView(entry: entry)
        }
        .configurationDisplayName("Heatmap Patchi")
        .description("Tes 7 derniers jours d'un coup d'œil.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct HeatmapTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> HeatmapEntry {
        HeatmapEntry(date: Date(), days: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (HeatmapEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HeatmapEntry>) -> Void) {
        // Charger les données depuis le App Group shared container
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}
```

---

_Document généré le 2026-04-01 — Sources : Apple Developer Documentation via context7_
