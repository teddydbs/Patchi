import SwiftUI

/// Formulaire d'auth email utilisé dans l'onboarding (step `.login`).
///
/// **Deux modes** :
/// - `signUp` (défaut) — Prénom + Email + Mot de passe → crée un compte Supabase
/// - `signIn` — Email + Mot de passe → connecte un user existant
///
/// L'utilisateur peut basculer entre les deux via un segmented control en haut.
/// En mode `signIn` un lien "Mot de passe oublié ?" apparaît pour déclencher
/// un reset via Supabase.
///
/// **Important** : la sheet ne se ferme PAS automatiquement au tap sur Continuer.
/// Elle attend la réussite du flow d'auth (appelé via `onSubmit`) et c'est le
/// parent qui décide de dismiss via le binding `isPresented` à false.
struct EmailSignInView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case signUp = "Créer un compte"
        case signIn = "Me connecter"
        var id: String { rawValue }
    }

    @Environment(\.dismiss) private var dismiss
    @State private var authService = AuthService.shared

    @State private var mode: Mode = .signUp
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var firstName: String = ""
    @State private var showPassword: Bool = false
    @State private var showResetPasswordConfirmation: Bool = false
    @State private var resetPasswordError: String?

    @FocusState private var focusedField: Field?
    enum Field { case firstName, email, password }

    /// Callback quand l'user submit le form. Le parent décide de la suite :
    /// - En cas de succès : dismiss + goNext sur l'onboarding
    /// - En cas d'erreur : garde la sheet ouverte + affiche l'erreur
    /// Le callback est async-friendly via `@MainActor`.
    let onSubmit: (_ mode: Mode, _ firstName: String, _ email: String, _ password: String) -> Void

    // MARK: - Validation

    private var canSubmit: Bool {
        guard isValidEmail(email) else { return false }
        switch mode {
        case .signUp:
            return !firstName.isBlank && password.count >= 6
        case .signIn:
            return !password.isEmpty
        }
    }

    private func isValidEmail(_ s: String) -> Bool {
        let pattern = #"^\S+@\S+\.\S+$"#
        return s.range(of: pattern, options: .regularExpression) != nil
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            formContent
                .navigationTitle(mode == .signUp ? "Créer un compte" : "Me connecter")
                .navigationBarTitleDisplayMode(.inline)
                .scrollDismissesKeyboard(.interactively)
                .disabled(authService.isAuthenticating)
                .toolbar { toolbarContent }
                .focusAfter {
                    focusedField = mode == .signUp ? .firstName : .email
                }
                .onChange(of: mode) { _, newMode in
                    focusedField = newMode == .signUp ? .firstName : .email
                }
                .modifier(EmailSignInAlerts(
                    showResetConfirmation: $showResetPasswordConfirmation,
                    errorMessage: $resetPasswordError
                ))
        }
        .interactiveDismissDisabled(authService.isAuthenticating)
    }

    // MARK: - Sub-views

    private var formContent: some View {
        Form {
            modeSection
            if mode == .signUp { firstNameSection }
            emailSection
            passwordSection
        }
    }

    private var modeSection: some View {
        Section {
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases) { m in
                    Text(m.rawValue).tag(m)
                }
            }
            .pickerStyle(.segmented)
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
    }

    private var firstNameSection: some View {
        Section {
            TextField("Comment on t'appelle ?", text: $firstName)
                .textContentType(.givenName)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .firstName)
                .submitLabel(.next)
                .onSubmit { focusedField = .email }
        } header: {
            Text("Prénom")
        }
    }

    private var emailSection: some View {
        Section {
            TextField("toi@exemple.fr", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocorrectionDisabled()
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .onSubmit { focusedField = .password }
        } header: {
            Text("Email")
        }
    }

    private var passwordSection: some View {
        Section {
            HStack {
                passwordField
                passwordVisibilityToggle
            }
        } header: {
            Text("Mot de passe")
        } footer: {
            passwordSectionFooter
        }
    }

    @ViewBuilder
    private var passwordField: some View {
        Group {
            if showPassword {
                TextField("6 caractères minimum", text: $password)
                    .autocorrectionDisabled()
            } else {
                SecureField("6 caractères minimum", text: $password)
            }
        }
        .textContentType(mode == .signUp ? .newPassword : .password)
        .focused($focusedField, equals: .password)
        .submitLabel(.done)
        .onSubmit { if canSubmit { submit() } }
    }

    private var passwordVisibilityToggle: some View {
        Button {
            showPassword.toggle()
        } label: {
            Image(systemName: showPassword ? "eye.slash" : "eye")
                .foregroundStyle(Color.mdTextGray)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var passwordSectionFooter: some View {
        if mode == .signIn {
            forgotPasswordButton
        } else {
            Text("Ton mot de passe est stocké de façon sécurisée sur Supabase.")
                .font(.caption2)
        }
    }

    private var forgotPasswordButton: some View {
        Button {
            Task { await requestPasswordReset() }
        } label: {
            Text("Mot de passe oublié ?")
                .font(.footnote)
                .foregroundStyle(Color.dsLink)
        }
        .buttonStyle(.plain)
        .disabled(!isValidEmail(email) || authService.isAuthenticating)
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Annuler") { dismiss() }
                .disabled(authService.isAuthenticating)
        }
        ToolbarItem(placement: .confirmationAction) {
            if authService.isAuthenticating {
                ProgressView()
            } else {
                Button(mode == .signUp ? "Créer" : "Connexion") {
                    submit()
                }
                .disabled(!canSubmit)
            }
        }
    }

    // MARK: - Actions

    private func submit() {
        onSubmit(mode, firstName.trimmed, email.trimmed, password)
        // La sheet reste ouverte : c'est le parent qui décide du dismiss
        // via le binding isPresented après succès de l'auth.
    }

    private func requestPasswordReset() async {
        let cleanedEmail = email.trimmed
        guard isValidEmail(cleanedEmail) else {
            resetPasswordError = "Saisis d'abord une adresse email valide."
            return
        }
        do {
            try await authService.resetPassword(email: cleanedEmail)
            showResetPasswordConfirmation = true
        } catch {
            resetPasswordError = AuthService.friendlyMessage(for: error)
        }
    }
}

// MARK: - Alerts modifier

/// Regroupe les alerts de l'écran pour alléger le body principal et
/// éviter le "type-check in reasonable time" du compilateur SwiftUI.
private struct EmailSignInAlerts: ViewModifier {
    @Binding var showResetConfirmation: Bool
    @Binding var errorMessage: String?

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )
    }

    func body(content: Content) -> some View {
        content
            .alert("Email envoyé", isPresented: $showResetConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Si un compte existe pour cet email, tu recevras un lien de réinitialisation dans quelques minutes.")
            }
            .alert("Erreur", isPresented: errorBinding) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "")
            }
    }
}

#Preview {
    EmailSignInView { mode, firstName, email, password in
        print("mode:", mode, "firstName:", firstName, "email:", email, "password:", password.count, "chars")
    }
}
