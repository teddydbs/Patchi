import SwiftUI
import SwiftData

@main
struct PatchiApp: App {
    @State private var appState = AppState()
    private let modelContainer: ModelContainer

    init() {
        let container = try! ModelContainer(for:
            User.self,
            CheckIn.self,
            AccountabilityEntry.self,
            Decision.self,
            FutureLetter.self
        )
        self.modelContainer = container
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .onAppear {
                    setupStoreKit()
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
