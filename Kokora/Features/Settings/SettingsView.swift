import SwiftUI
import SwiftData
import AuthenticationServices

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Query private var users: [User]

    @State private var authService = AuthService.shared
    @State private var biometricService = BiometricService.shared
    @State private var storeKit = StoreKitService.shared
    @State private var showPremium = false
    @State private var showDeleteAccountConfirm = false
    @State private var deleteAccountError: String?

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
            .confirmationDialog(
                "Supprimer définitivement ton compte ?",
                isPresented: $showDeleteAccountConfirm,
                titleVisibility: .visible
            ) {
                Button("Supprimer mon compte", role: .destructive) {
                    Task { await deleteAccount() }
                }
                Button("Annuler", role: .cancel) { }
            } message: {
                Text("Cette action est irréversible. Tous tes check-ins, décisions, lettres et accountability seront supprimés. Ton compte ne pourra pas être récupéré.")
            }
            .alert("Erreur", isPresented: Binding(
                get: { deleteAccountError != nil },
                set: { if !$0 { deleteAccountError = nil } }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(deleteAccountError ?? "")
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
                        .foregroundStyle(Color.mdGreen)
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
                    Task {
                        await fullSignOut()
                    }
                }

                Button("Supprimer mon compte", role: .destructive) {
                    showDeleteAccountConfirm = true
                }
            } else {
                // Bouton natif Sign in with Apple — backed by Supabase Auth.
                // Pour le vrai flow avec nonce, utiliser le loginStep de l'onboarding.
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { _ in
                    // L'utilisateur devrait normalement passer par l'onboarding.
                    // Depuis les Settings, ce bouton est juste un fallback.
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
        }
    }

    // MARK: - Sign out (full clean)

    /// Déconnexion complète : Supabase + SwiftData + AppState.
    /// L'utilisateur est ramené à l'onboarding au prochain lancement.
    private func fullSignOut() async {
        // 1. Sign out Supabase (clear keychain session)
        try? await authService.signOut()

        // 2. Clean local data + reset AppState
        await cleanLocalUserData()
    }

    /// Suppression définitive du compte : appelle la RPC Supabase
    /// `delete_account()` (cascade delete sur toutes les tables user-owned)
    /// puis clean le local et ramène l'utilisateur à l'onboarding.
    private func deleteAccount() async {
        do {
            try await authService.deleteAccount()
            await cleanLocalUserData()
        } catch {
            await MainActor.run {
                deleteAccountError = AuthService.friendlyMessage(for: error)
            }
        }
    }

    /// Nettoyage du cache local après signOut ou deleteAccount.
    /// Supprime tous les Users SwiftData et reset `AppState.isOnboardingCompleted`.
    private func cleanLocalUserData() async {
        await MainActor.run {
            for u in users {
                modelContext.delete(u)
            }
            try? modelContext.save()
            appState.isOnboardingCompleted = false
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
                    Label("Kokora Premium", systemImage: "crown.fill")
                        .foregroundStyle(Color.mdYellow)
                    Spacer()
                    Text("Actif")
                        .font(.caption)
                        .foregroundStyle(Color.mdGreen)
                        .fontWeight(.medium)
                }
            } else {
                Button {
                    showPremium = true
                } label: {
                    HStack {
                        Label("Découvrir Premium", systemImage: "crown.fill")
                            .foregroundStyle(Color.mdYellow)
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
            .background(Capsule().fill(Color.mdGreenBg))
            .foregroundStyle(Color.mdGreen)
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
                        .tint(Color.mdGreen)

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
                        .tint(Color.mdGreen)
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
            Text("Mentions légales\n\nKokora est une application de journaling personnel développée pour iOS.\n\nVos données (check-ins, décisions, lettres, accountability) sont hébergées sur Supabase, dans des datacenters situés dans l'Union Européenne (Frankfurt, Allemagne), conformément au RGPD.\n\nUne copie locale est également conservée sur votre appareil via SwiftData pour permettre l'utilisation hors ligne.\n\nVous pouvez supprimer l'intégralité de vos données à tout moment depuis les réglages de l'application (action irréversible, cascade côté serveur).")
                .padding()
        }
        .navigationTitle("Mentions légales")
    }
}

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            Text("Politique de confidentialité\n\nKokora respecte ta vie privée.\n\n• Authentification via Sign in with Apple, Google ou email/mot de passe, gérée par Supabase Auth\n• Données hébergées en UE (Frankfurt) conformément au RGPD\n• Sécurité enforcée côté serveur via Row Level Security Postgres — chaque utilisateur ne voit que ses propres données\n• Aucun tracking, aucune publicité, aucun partage avec des tiers\n• Pas d'IA, pas de modèle génératif, pas d'analyse de tes textes\n• Tu peux supprimer toutes tes données à tout moment depuis les réglages\n\nContact : support@kokora.app")
                .padding()
        }
        .navigationTitle("Confidentialité")
    }
}
