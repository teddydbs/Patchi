import GoogleSignIn
import SwiftUI
import SwiftData

@main
struct KokoraApp: App {
    @State private var appState = AppState()
    private let modelContainer: ModelContainer

    init() {
        do {
            self.modelContainer = try ModelContainer(for:
                User.self, CheckIn.self, AccountabilityEntry.self, Decision.self, FutureLetter.self
            )
        } catch {
            // Base corrompue ou migration échouée — supprimer et recréer
            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let storeURL = appSupport.appendingPathComponent("default.store")
            for ext in ["", ".wal", ".shm"] {
                let url = ext.isEmpty ? storeURL : storeURL.appendingPathExtension(ext)
                try? FileManager.default.removeItem(at: url)
            }
            // Retenter avec une base propre — si ça échoue encore, c'est un bug fatal
            self.modelContainer = try! ModelContainer(for:
                User.self, CheckIn.self, AccountabilityEntry.self, Decision.self, FutureLetter.self
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .onAppear {
                    setupStoreKit()
                }
                .onOpenURL { url in
                    // Redirect du flow GoogleSignIn (scheme reversed client ID)
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
        .modelContainer(modelContainer)
    }

    private func setupStoreKit() {
        let storeKit = StoreKitService.shared
        let context = modelContainer.mainContext

        storeKit.onPremiumChanged = { isPremium in
            appState.isPremium = isPremium
            // Sync vers SwiftData
            let descriptor = FetchDescriptor<User>()
            if let user = try? context.fetch(descriptor).first {
                user.isPremium = isPremium
            }
        }

        storeKit.start()
    }
}
