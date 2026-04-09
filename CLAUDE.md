# Project: Kokora — Journal d'intégrité personnelle

> **Taskmaster-Managed iOS Project**

## Project Overview

App iOS native en SwiftUI pour le journaling émotionnel, l'accountability personnel, et le journal de décisions. En français natif. Mascotte Kokora (petite patate orange chibi).

**Key Documents:**
- PRD: `.taskmaster/docs/prd.md` - Product requirements complets
- Tasks: `.taskmaster/tasks/tasks.json` - 40 tâches avec dépendances
- Spec originale: `Application iOS Journal de Décisions.md`

---

## Tech Stack

| Couche | Technologie |
|--------|------------|
| UI Framework | SwiftUI — iOS 17+ |
| Language | Swift 5.9 |
| Cache local | SwiftData — @Model (offline-first) |
| Backend | **Supabase** (Postgres + Auth + Storage, EU hosting) |
| Backend SDK | `supabase-swift` 2.43+ via SPM |
| State | @Observable + @Environment |
| Auth | Sign in with Apple (natif) + Google (planifié) + Email/password — tous via Supabase Auth |
| Speech | SFSpeechRecognizer + AVFoundation |
| Notifications | UserNotifications |
| Monetisation | StoreKit 2 |
| Biometrie | LocalAuthentication |
| Widget | WidgetKit + AppIntents (V1.1) |
| Architecture | MVVM |
| Animations | Lottie (lottie-ios via SPM) |
| Build | XcodeGen |

## Architecture

```
Kokora/
├── App/          → KokoraApp.swift, AppState, AppRouter
├── Models/       → @Model SwiftData (User, CheckIn, AccountabilityEntry, Decision, FutureLetter)
│   └── Enums/    → Emotion, Activity, HeatmapColor, Verdict, DecisionStatus, AppTheme
├── Features/     → Un dossier par feature (View + ViewModel)
│   ├── Onboarding/
│   ├── Home/
│   ├── CheckIn/
│   ├── Accountability/
│   ├── Decisions/
│   ├── Stats/
│   ├── Journal/
│   ├── Letters/
│   ├── Quotes/
│   └── Settings/
├── Services/     → SupabaseClient (singleton), AuthService (Apple/Email/Google),
│                   NotificationService, SpeechService, StoreKitService, HeatmapService,
│                   ReformulationService, InsightService, BiometricService
├── Components/   → Kokora/, HeatmapGrid/, MoodSlider/, VoiceInput/, PremiumGate/, CalendarStrip/
├── Extensions/   → Color+Mood, Date+Helpers, View+Transitions
└── Resources/    → Localizable.strings, Assets.xcassets, Fonts/, Animations/
```

## Décisions clés

- **Pas d'IA** — L'utilisateur est son propre juge. Zéro coût API.
- **Backend Supabase** (depuis 2026-04-09) — Postgres + Auth + Storage, hosting EU (Frankfurt) pour GDPR. Cache local SwiftData reste pour offline-first.
- **Row Level Security** — Chaque user ne voit QUE ses propres données via les policies Postgres. Sécurité enforced côté serveur, jamais côté client.
- **3 méthodes d'auth** — Sign in with Apple, Google, Email/password — tous routés via Supabase Auth. Le `firstName` est récupéré du provider quand possible, sinon demandé via fallback.
- **Bypass onboarding pour users existants** — `profiles.onboarding_completed` est lu après login ; si `true`, l'app skip toutes les étapes et file direct au Home.
- **Français natif** — Tout en français, pas traduit. Tutoiement.
- **Couleurs vives** — Palette saturée et énergique pour les couleurs d'humeur.
- **Freemium** — Toutes les saisies gratuites, analyses avancées en premium (~35€/an).
- **StoreKit 2** — Trial 7 jours sans CB via introductoryOffer.
- **Conversion au J+30** — Premier moment de vérité = meilleur moment de conversion.

## Typographie

- **Crimson Pro italique** — Titres, questions Kokora, citations, reformulations (émotionnel)
- **SF Pro (système)** — Labels, data, interface (fonctionnel)

## Couleurs d'humeur (vives)

| Score | Couleur |
|-------|---------|
| 5 | Jaune soleil vif |
| 4 | Vert émeraude franc |
| 3 | Beige chaud |
| 2 | Violet doux |
| 1 | Bleu nuit profond |
| Stress | Orange vif |
| Colère | Rouge corail |

## Taskmaster Commands

```bash
task-master list                     # Voir toutes les tâches
task-master show <id>                # Détails d'une tâche
task-master next                     # Prochaine tâche disponible
task-master set-status --id=<id> --status=in-progress
task-master set-status --id=<id> --status=done
```

## Animations — Lottie

**Dépendance:** `lottie-ios` via SPM (`https://github.com/airbnb/lottie-ios`)

### Workflow
1. Création dans **After Effects** (plugin Bodymovin) ou éditeur **LottieFiles.com**
2. Export en `.lottie` (compressé) ou `.json`
3. Fichiers placés dans `Kokora/Resources/Animations/`
4. Intégration via `LottieView` en SwiftUI

### Convention de nommage des fichiers
```
kokora_{état}_{variante}.lottie
```
Exemples : `kokora_idle_breathing.lottie`, `kokora_happy_bounce.lottie`, `kokora_sad_comfort.lottie`, `kokora_celebrate_confetti.lottie`

### Animations Kokora prévues

| État | Description | Usage |
|------|-------------|-------|
| `idle_breathing` | Respiration douce, yeux ouverts | État par défaut sur Home |
| `happy_bounce` | Saut joyeux, yeux plissés | Check-in humeur 4-5 |
| `sad_comfort` | Expression douce, câlin | Check-in humeur 1-2 |
| `thinking` | Tête penchée, points de suspension | Pendant saisie/réflexion |
| `celebrate_confetti` | Explosion de joie + confettis | Streak atteint, objectif complété |
| `encourage` | Pouce levé, clin d'œil | Rappel de revenir, motivation |
| `wave_hello` | Salut de la main | Onboarding, retour après absence |
| `sleep` | Yeux fermés, Zzz | Mode nuit, inactivité |

### Règles d'utilisation
- **Transitions d'humeur** : morphing via segments d'animation (ex: frame 0-30 = idle → happy)
- **Performance** : toujours utiliser `.loopMode(.loop)` pour idle, `.loopMode(.playOnce)` pour réactions
- **Taille** : animations max 150KB chacune, 512x512pt de résolution
- **Couleurs** : les couleurs de Kokora (orange #FF8C42) doivent être paramétrables via `ColorValueProvider` pour s'adapter au thème
- **Spring natif** : garder `withAnimation(.spring(response: 0.4, dampingFraction: 0.7))` pour les transitions UI autour des animations Lottie
- **Haptics** : coupler les moments clés des animations avec `UIImpactFeedbackGenerator` (celebrate → .heavy, encourage → .light)

### Intégration SwiftUI type
```swift
import Lottie

struct KokoraAnimatedView: View {
    let state: KokoraState
    
    var body: some View {
        LottieView(animation: .named("kokora_\(state.animationName)"))
            .playing(loopMode: state.isLooping ? .loop : .playOnce)
            .frame(width: 200, height: 200)
    }
}
```

## Règles

- Lire le PRD (`.taskmaster/docs/prd.md`) au début de chaque conversation
- Les données sensibles transitent par Supabase (HTTPS, RLS enforced) et sont cachées en local SwiftData pour l'offline
- Jamais stocker la `service_role` key Supabase dans le client — seule la `publishable` key est OK
- Ne jamais utiliser `rm` — utiliser `trash` à la place
- Utiliser `/swiftui-pro` pour review le code SwiftUI
- Utiliser `/verification-before-completion` avant de commit
- **Après chaque `xcodegen generate`** : ré-écrire `Kokora/Kokora.entitlements` avec Sign in with Apple (XcodeGen l'écrase)
