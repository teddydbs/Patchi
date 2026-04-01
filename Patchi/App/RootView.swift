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
        }
    }
}
