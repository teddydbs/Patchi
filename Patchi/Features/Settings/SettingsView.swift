import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query private var users: [User]

    @State private var authService = AuthService.shared
    @State private var biometricService = BiometricService.shared
    @State private var storeKit = StoreKitService.shared
    @State private var showPremium = false

    private var user: User? { users.first }

    var body: some View {
        NavigationStack {
            List {
                // Compte
                accountSection

                // Notifications
                notificationSection

                // Apparence
                appearanceSection

                // Sécurité
                securitySection

                // Premium
                premiumSection

                // À propos
                aboutSection
            }
            .navigationTitle("Réglages")
            .sheet(isPresented: $showPremium) {
                PremiumView()
            }
        }
    }

    // MARK: - Compte

    private var accountSection: some View {
        Section("Compte") {
            if authService.isSignedIn {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user?.firstName ?? "Utilisateur")
                            .fontWeight(.medium)
                        if let email = user?.email {
                            Text(email)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Button("Se déconnecter", role: .destructive) {
                    authService.signOut()
                }
            } else {
                AppleSignInButton()
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
    }

    // MARK: - Notifications

    private var notificationSection: some View {
        Section("Notifications") {
            NavigationLink {
                NotificationSettingsView()
            } label: {
                Label("Configurer les rappels", systemImage: "bell.fill")
            }
        }
    }

    // MARK: - Apparence

    private var appearanceSection: some View {
        Section("Apparence") {
            if let user {
                Picker("Thème", selection: Binding(
                    get: { AppTheme(rawValue: user.selectedTheme) ?? .default },
                    set: { user.selectedTheme = $0.rawValue }
                )) {
                    ForEach(AppTheme.allCases) { theme in
                        Text(theme.displayName).tag(theme)
                    }
                }
            }
        }
    }

    // MARK: - Sécurité

    private var securitySection: some View {
        Section("Sécurité") {
            if biometricService.isAvailable {
                if appState.isPremium {
                    Toggle(isOn: Binding(
                        get: { user?.biometricLockEnabled ?? false },
                        set: { newValue in
                            Task {
                                if newValue {
                                    let success = await biometricService.authenticate()
                                    if success { user?.biometricLockEnabled = true }
                                } else {
                                    user?.biometricLockEnabled = false
                                }
                            }
                        }
                    )) {
                        Label(biometricService.biometryName, systemImage: biometricService.biometryIcon)
                    }
                } else {
                    HStack {
                        Label(biometricService.biometryName, systemImage: biometricService.biometryIcon)
                        Spacer()
                        premiumBadge
                    }
                    .onTapGesture { showPremium = true }
                }
            }
        }
    }

    // MARK: - Premium

    private var premiumSection: some View {
        Section("Premium") {
            if appState.isPremium {
                HStack {
                    Label("Patchi Premium", systemImage: "crown.fill")
                        .foregroundStyle(.orange)
                    Spacer()
                    Text("Actif")
                        .font(.caption)
                        .foregroundStyle(.green)
                        .fontWeight(.medium)
                }
            } else {
                Button {
                    showPremium = true
                } label: {
                    HStack {
                        Label("Découvrir Premium", systemImage: "crown.fill")
                            .foregroundStyle(.orange)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Button("Restaurer les achats") {
                Task { await storeKit.restore() }
            }
            .font(.subheadline)
        }
    }

    // MARK: - À propos

    private var aboutSection: some View {
        Section("À propos") {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundStyle(.secondary)
            }

            NavigationLink("Mentions légales") {
                LegalView()
            }

            NavigationLink("Politique de confidentialité") {
                PrivacyView()
            }
        }
    }

    private var premiumBadge: some View {
        Text("Premium")
            .font(.system(size: 10, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color.orange.opacity(0.15)))
            .foregroundStyle(.orange)
    }
}

// MARK: - Notification Settings

struct NotificationSettingsView: View {
    @Query private var users: [User]
    private var user: User? { users.first }

    var body: some View {
        List {
            Section("Plage horaire") {
                if let user {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Début")
                            Spacer()
                            Text("\(user.notificationStartHour)h00")
                                .fontWeight(.medium)
                        }
                        Slider(
                            value: Binding(
                                get: { Double(user.notificationStartHour) },
                                set: { user.notificationStartHour = Int($0) }
                            ),
                            in: 6...22,
                            step: 1
                        )
                        .tint(.orange)

                        HStack {
                            Text("Fin")
                            Spacer()
                            Text("\(user.notificationEndHour)h00")
                                .fontWeight(.medium)
                        }
                        Slider(
                            value: Binding(
                                get: { Double(user.notificationEndHour) },
                                set: { user.notificationEndHour = Int($0) }
                            ),
                            in: Double(user.notificationStartHour + 1)...23,
                            step: 1
                        )
                        .tint(.orange)
                    }
                }
            }

            Section("Nombre de rappels par jour") {
                if let user {
                    Stepper(
                        "\(user.notificationCount) rappel\(user.notificationCount > 1 ? "s" : "")",
                        value: Binding(
                            get: { user.notificationCount },
                            set: { user.notificationCount = $0 }
                        ),
                        in: 1...5
                    )
                }
            }

            Section {
                Button("Appliquer") {
                    guard let user else { return }
                    NotificationService.shared.scheduleEveningNotifications(
                        startHour: user.notificationStartHour,
                        endHour: user.notificationEndHour,
                        count: user.notificationCount
                    )
                    NotificationService.shared.scheduleSundayRitual()
                }
                .fontWeight(.medium)
            }

            Section("Types de notifications") {
                Label("Soir — rappel quotidien", systemImage: "moon.fill")
                Label("Décision — rappels J+30 et J+90", systemImage: "arrow.triangle.branch")
                Label("Lettre — livraison à 6 mois", systemImage: "envelope.fill")
                Label("Dimanche — rituel hebdo à 19h", systemImage: "calendar")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .navigationTitle("Notifications")
    }
}

// MARK: - Legal & Privacy Placeholders

struct LegalView: View {
    var body: some View {
        ScrollView {
            Text("Mentions légales\n\nPatchi est une application de journaling personnel. Toutes les données sont stockées localement sur votre appareil via SwiftData.\n\nAucune donnée personnelle n'est collectée ni transmise à des serveurs tiers.\n\nLa synchronisation iCloud (premium) utilise CloudKit et est chiffrée de bout en bout par Apple.")
                .padding()
        }
        .navigationTitle("Mentions légales")
    }
}

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            Text("Politique de confidentialité\n\nPatchi respecte votre vie privée.\n\n• Vos données restent sur votre appareil\n• Aucun tracking, aucune publicité\n• Pas d'IA externe, pas d'API tierce\n• La synchronisation iCloud (premium) est chiffrée par Apple\n• Vous pouvez supprimer toutes vos données à tout moment\n\nContact : support@patchi.app")
                .padding()
        }
        .navigationTitle("Confidentialité")
    }
}
