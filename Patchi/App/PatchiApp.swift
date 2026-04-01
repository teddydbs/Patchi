import SwiftUI
import SwiftData

@main
struct PatchiApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .onAppear {
                    setupStoreKit()
                }
        }
        .modelContainer(for: [
            User.self,
            CheckIn.self,
            AccountabilityEntry.self,
            Decision.self,
            FutureLetter.self
        ])
    }

    private func setupStoreKit() {
        let storeKit = StoreKitService.shared
        storeKit.onPremiumChanged = { isPremium in
            appState.isPremium = isPremium
        }
        storeKit.start()
    }
}
