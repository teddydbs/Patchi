import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]

    var body: some View {
        Group {
            if !appState.isOnboardingCompleted && users.isEmpty {
                OnboardingView()
            } else {
                MainTabView()
            }
        }
        .onAppear {
            if let user = users.first, user.onboardingCompleted {
                appState.isOnboardingCompleted = true
                appState.isPremium = user.isPremium
            }

            // Sync StoreKit → SwiftData User quand le statut premium change
            StoreKitService.shared.onPremiumChanged = { [weak appState] isPremium in
                appState?.isPremium = isPremium
                if let user = users.first {
                    user.isPremium = isPremium
                }
            }
        }
    }
}
