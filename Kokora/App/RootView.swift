import SwiftUI
import SwiftData

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @Query private var letters: [FutureLetter]

    var body: some View {
        Group {
            if !appState.isOnboardingCompleted && users.isEmpty {
                OnboardingView()
            } else if needsBiometricUnlock && !appState.isUnlocked {
                biometricLockScreen
            } else {
                MainTabView()
            }
        }
        .onAppear {
            if let user = users.first, user.onboardingCompleted {
                appState.isOnboardingCompleted = true
                // Ne pas lire isPremium depuis SwiftData — StoreKit est la source de vérité.
                // appState.isPremium reste false jusqu'à confirmation de refreshEntitlements().

                // Si biometric lock pas activé, déverrouiller directement
                if !user.biometricLockEnabled {
                    appState.isUnlocked = true
                }
            }
            // Marquer les lettres dont la date de livraison est passée comme livrées
            for letter in letters where !letter.isDelivered && letter.deliverAt <= Date() {
                letter.isDelivered = true
            }
        }
    }

    private var needsBiometricUnlock: Bool {
        users.first?.biometricLockEnabled == true
    }

    private var biometricLockScreen: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: BiometricService.shared.biometryIcon)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("Déverrouille ton journal")
                .font(.title3)
                .fontWeight(.medium)
            Button("Déverrouiller") {
                Task {
                    let success = await BiometricService.shared.authenticate()
                    if success {
                        appState.isUnlocked = true
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            Spacer()
        }
        .onAppear {
            Task {
                let success = await BiometricService.shared.authenticate()
                if success {
                    appState.isUnlocked = true
                }
            }
        }
    }
}
