import SwiftUI
import SwiftData
import AuthenticationServices
import CryptoKit

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Environment(\.colorScheme) private var colorScheme
    @State private var viewModel = OnboardingViewModel()
    @State private var authService = AuthService.shared

    // Sheets / alerts pilotés depuis le loginStep
    @State private var showEmailSheet: Bool = false
    @State private var showGoogleAlert: Bool = false
    @State private var showFirstNameFallback: Bool = false
    @State private var showAuthErrorAlert: Bool = false
    @State private var authErrorMessage: String = ""

    /// Nonce en clair généré avant le request Apple et ré-utilisé pour la
    /// vérification de l'id_token par Supabase.
    @State private var currentAppleNonce: String?

    var body: some View {
        ZStack {
            // Fond
            backgroundColor
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: viewModel.currentStep)

            VStack(spacing: 0) {
                // Progress bar
                if viewModel.currentStep != .welcome {
                    progressBar
                }

                // Contenu — ZStack + transition manuelle (pas de TabView → pas de swipe possible)
                ZStack {
                    Group {
                        switch viewModel.currentStep {
                        case .welcome: welcomeStep
                        case .login: loginStep
                        case .firstQuestion: firstQuestionStep
                        case .reformulation: reformulationStep
                        case .firstSquare: firstSquareStep
                        case .reminders: remindersStep
                        case .trial: trialStep
                        case .account: accountStep
                        }
                    }
                    .id(viewModel.currentStep)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .move(edge: .leading)
                    ))
                }
                .animation(.easeInOut(duration: 0.5), value: viewModel.currentStep)
            }
            // Welcome & Login sont décoratifs bord-à-bord : on laisse le VStack
            // s'étendre dans la safe area pour que les illustrations atteignent le bas.
            .ignoresSafeArea(edges: isDecorativeStep ? .all : [])
        }
        // Email auth sheet (step login) — 2 modes : signUp / signIn
        .sheet(isPresented: $showEmailSheet) {
            EmailSignInView { mode, firstName, emailValue, password in
                Task {
                    do {
                        switch mode {
                        case .signUp:
                            try await AuthService.shared.signUpWithEmail(
                                email: emailValue,
                                password: password,
                                firstName: firstName
                            )
                        case .signIn:
                            try await AuthService.shared.signInWithEmail(
                                email: emailValue,
                                password: password
                            )
                        }

                        await MainActor.run {
                            // Pour signIn, on lit le prénom depuis le profile fetché
                            // par handleSessionChange. Pour signUp, on a le prénom du form.
                            let resolvedName = mode == .signIn
                                ? authService.currentFirstName
                                : firstName
                            viewModel.firstName = resolvedName.isEmpty ? firstName : resolvedName
                            viewModel.email = emailValue
                            Haptics.success()
                            showEmailSheet = false
                            advanceAfterLogin()
                        }
                    } catch {
                        await MainActor.run {
                            Haptics.warning()
                            authErrorMessage = AuthService.friendlyMessage(for: error)
                            showAuthErrorAlert = true
                            // ⚠️ On ne ferme PAS la sheet : l'user voit l'alerte par-dessus
                            // et peut corriger ses credentials
                        }
                    }
                }
            }
        }
        // Fallback prénom : déclenché quand Apple ne fournit pas de nom.
        // Met aussi à jour le profile Supabase côté serveur.
        .sheet(isPresented: $showFirstNameFallback) {
            FirstNameFallbackView { firstName in
                Task {
                    if let userId = AuthService.shared.currentUserId {
                        try? await AuthService.shared.updateProfile(userId: userId, firstName: firstName)
                    }
                    await MainActor.run {
                        viewModel.firstName = firstName
                        Haptics.success()
                        advanceAfterLogin()
                    }
                }
            }
        }
        // Alerte d'erreur d'auth (Apple, Google, Email)
        .alert("Erreur", isPresented: $showAuthErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authErrorMessage)
        }
        // Restauration de session : si l'user était déjà signé in au lancement
        // ET que son profile a onboarding_completed=true, on file direct au Home.
        // (Le bootstrap de AuthService est async, donc on observe via onChange.)
        .onChange(of: authService.isSignedIn) { _, signedIn in
            if signedIn && authService.currentProfileOnboardingCompleted && !appState.isOnboardingCompleted {
                viewModel.complete(context: modelContext, appState: appState)
            }
        }
        .onChange(of: authService.currentProfileOnboardingCompleted) { _, completed in
            if authService.isSignedIn && completed && !appState.isOnboardingCompleted {
                viewModel.complete(context: modelContext, appState: appState)
            }
        }
        // Google sign-in stub alert (SDK pas encore intégré)
        .alert("Connexion Google", isPresented: $showGoogleAlert) {
            Button("J'ai compris", role: .cancel) { }
        } message: {
            Text("L'authentification Google nécessite le SDK GoogleSignIn-iOS et un client OAuth 2.0 configuré sur Google Cloud. Utilise Apple ou Email pour l'instant.")
        }
    }

    /// Les étapes qui s'étendent bord-à-bord (illustrations décoratives atteignant les bords).
    private var isDecorativeStep: Bool {
        viewModel.currentStep == .welcome || viewModel.currentStep == .login
    }

    /// Traite le résultat d'un Sign in with Apple et délègue à Supabase via
    /// `AuthService.signInWithApple(credential:rawNonce:)`.
    ///
    /// Flow :
    /// 1. Le bouton a déjà stocké le nonce en clair dans `currentAppleNonce`
    ///    et passé son hash SHA256 à `ASAuthorizationAppleIDRequest.nonce`.
    /// 2. Apple renvoie un id_token signé (qui contient le hash).
    /// 3. On envoie id_token + nonce en clair à Supabase, qui vérifie que le
    ///    hash match puis crée/récupère la session.
    /// 4. Si Apple n'a pas fourni de prénom (2e sign-in, masqué), on montre
    ///    le fallback `FirstNameFallbackView`.
    /// 5. Si le profile Supabase a `onboarding_completed = true`, on bypass
    ///    le reste de l'onboarding et file direct au Home.
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard
                let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let rawNonce = currentAppleNonce,
                let credentials = AppleCredentials(credential: appleCredential, rawNonce: rawNonce)
            else {
                Haptics.warning()
                authErrorMessage = "Impossible de vérifier l'authentification Apple."
                showAuthErrorAlert = true
                return
            }

            if let emailValue = appleCredential.email, !emailValue.isEmpty {
                viewModel.email = emailValue
            }

            Task {
                do {
                    let givenName = try await AuthService.shared.signInWithApple(credentials)

                    // Nettoyage du nonce (usage unique)
                    await MainActor.run { currentAppleNonce = nil }

                    if let name = givenName, !name.isEmpty {
                        await MainActor.run {
                            viewModel.firstName = name
                            Haptics.success()
                            advanceAfterLogin()
                        }
                    } else {
                        // Apple n'a pas fourni de nom → fallback sheet
                        // (sauf si c'est un user existant qui a un profile avec un nom)
                        await MainActor.run {
                            let existingName = authService.currentFirstName
                            if !existingName.isEmpty {
                                viewModel.firstName = existingName
                                Haptics.success()
                                advanceAfterLogin()
                            } else {
                                showFirstNameFallback = true
                            }
                        }
                    }
                } catch {
                    await MainActor.run {
                        print("[Login] Supabase Apple sign-in failed: \(error.localizedDescription)")
                        Haptics.warning()
                        authErrorMessage = AuthService.friendlyMessage(for: error)
                        showAuthErrorAlert = true
                        currentAppleNonce = nil
                    }
                }
            }

        case .failure(let error):
            // Annulation utilisateur ou erreur réseau. Pas d'alerte si cancel.
            let nsError = error as NSError
            if nsError.code != ASAuthorizationError.canceled.rawValue {
                print("[Login] Sign in with Apple failed: \(error.localizedDescription)")
                Haptics.warning()
                authErrorMessage = AuthService.friendlyMessage(for: error)
                showAuthErrorAlert = true
            }
            currentAppleNonce = nil
        }
    }

    /// Appelé après un login réussi (Apple ou Email). Décide :
    /// - Si `onboarding_completed == true` dans le profile Supabase → bypass
    ///   toutes les étapes restantes et file au Home (via `complete()`)
    /// - Sinon → continue l'onboarding normalement avec `goNext()`
    private func advanceAfterLogin() {
        if authService.currentProfileOnboardingCompleted {
            // User existant qui se reconnecte — on skip tout
            viewModel.complete(context: modelContext, appState: appState)
        } else {
            // Nouveau user — continue l'onboarding
            viewModel.goNext()
        }
    }

    // MARK: - Nonce helpers for Supabase Sign in with Apple

    /// Génère un nonce aléatoire cryptographiquement sûr (32 chars alphanumériques).
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("[Nonce] Unable to generate nonce: OSStatus \(errorCode)")
                }
                return random
            }

            for random in randoms where remainingLength > 0 {
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    /// SHA256 hex-encoded d'une string UTF-8. Utilisé pour le hash du nonce
    /// passé à `ASAuthorizationAppleIDRequest.nonce`.
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }

    private var backgroundColor: Color {
        switch viewModel.currentStep {
        case .welcome: return Color(red: 0.96, green: 0.96, blue: 0.96) // #F5F5F5
        case .login: return Color(red: 0.96, green: 0.96, blue: 0.96) // #F5F5F5
        case .firstQuestion: return Color.mdPurpleBg
        case .reformulation: return Color.mdGreenBg
        case .firstSquare: return Color.mdBg
        case .reminders: return Color.mdBg
        case .trial: return Color.mdBg
        case .account: return Color.mdBg
        }
    }

    // MARK: - Progress

    private var progressBar: some View {
        GeometryReader { geo in
            Capsule()
                .fill(Color.mdBorder)
                .frame(height: 4)
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(Color.mdGreen)
                        .frame(width: geo.size.width * viewModel.progress, height: 4)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.progress)
                }
        }
        .frame(height: 4)
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // MARK: - Step 1: Welcome

    private var welcomeStep: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Background
                Color(red: 0.96, green: 0.96, blue: 0.96)

                // -- Blobs — X/size = % of width, Y = % of height --
                // Figma ref: 393×852. position(x: figmaX/393, y: figmaY/852)
                // Chaque illustration flotte légèrement (FloatingEmotionImage).
                Group {
                    FloatingEmotionImage(name: "emotion_amoureux",
                        width: w * 0.548, baseRotation: 23.72,
                        x: w * 0.176, y: h * 0.405,
                        phaseDelay: 0.0)

                    FloatingEmotionImage(name: "emotion_nostalgique",
                        width: w * 0.555, baseRotation: 0,
                        x: w * 0.774, y: h * 0.372,
                        phaseDelay: 0.4)

                    FloatingEmotionImage(name: "emotion_serein",
                        width: w * 0.341, baseRotation: -11.32,
                        x: w * 0.051, y: h * 0.675,
                        phaseDelay: 0.8)

                    FloatingEmotionImage(name: "emotion_chanceux",
                        width: w * 0.450, baseRotation: -7.02,
                        x: w * 0.458, y: h * 0.635,
                        phaseDelay: 1.2)

                    FloatingEmotionImage(name: "emotion_confus",
                        width: w * 0.392, baseRotation: 0,
                        x: w * 0.878, y: h * 0.575,
                        phaseDelay: 0.6)

                    FloatingEmotionImage(name: "emotion_enerve",
                        width: w * 0.455, baseRotation: -17.23,
                        x: w * 0.204, y: h * 0.94,
                        phaseDelay: 1.5)

                    FloatingEmotionImage(name: "emotion_surpris",
                        width: w * 0.555, baseRotation: 4.28,
                        x: w * 0.738, y: h * 0.895,
                        phaseDelay: 0.2)
                }

                // -- Backdrop blur + gradient fade at bottom (Figma spec: 393x253, backdrop-blur 6.25px) --
                VStack {
                    Spacer()
                    ZStack {
                        // Backdrop blur subtil (opacity réduite pour moins d'intensité)
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .opacity(0.65)

                        // Teinte dégradée blanche par-dessus
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 0.85, green: 0.85, blue: 0.85).opacity(0), location: 0.00),
                                Gradient.Stop(color: .white.opacity(0.5), location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                    }
                    .frame(width: w, height: 215)
                    // Mask : blur invisible en haut, progressif, plein en bas
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: .black, location: 0.55),
                                .init(color: .black, location: 1.0),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)

                // -- Title + Subtitle + Button --
                VStack(spacing: 0) {
                    // Title area
                    VStack(spacing: 16) {
                        Text("Pas Sûr De\nTon Humeur ?")
                            .font(.kokoraDisplay(min(w * 0.102, 42), weight: .semibold))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)

                        Text("Prends un moment pour toi et reconnecte\ntoi à tes émotions.")
                            .font(.kokoraDisplay(min(w * 0.041, 16), weight: .regular))
                            .foregroundStyle(Color(red: 0.969, green: 0.447, blue: 0.216))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, h * 0.06)

                    Spacer()

                    // Button pinned to bottom
                    Button {
                        viewModel.goNext()
                    } label: {
                        Text("Continuer")
                            .font(.kokoraDisplay(20, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(red: 0.059, green: 0.059, blue: 0.059))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                    .padding(.horizontal, 34)
                    .padding(.bottom, 16)
                }
            }
        }
    }

    // MARK: - Step 2: Login — "On fait connaissance ?"
    //
    // Design de référence: Figma node 30:235 (canvas 393x852)
    // 5 illustrations flottantes + 3 boutons d'auth (Apple / Google / Email)
    // Le prénom est récupéré via l'auth provider quand possible, sinon
    // demandé dans un fallback (TODO : implémenter l'auth réelle).

    private var loginStep: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // -- Background --
                Color(red: 0.96, green: 0.96, blue: 0.96)

                // -- Illustrations (positions en % du Figma 393x852) --
                Group {
                    FloatingEmotionImage(
                        name: "emotion_heureux",
                        width: w * 0.524, baseRotation: 17.67,
                        x: w * 0.115, y: h * 0.388,
                        phaseDelay: 0.0
                    )

                    FloatingEmotionImage(
                        name: "emotion_serein",
                        width: w * 0.469, baseRotation: -18.8,
                        x: w * 0.814, y: h * 0.387,
                        phaseDelay: 0.4
                    )

                    FloatingEmotionImage(
                        name: "emotion_calme",
                        width: w * 0.433, baseRotation: 0,
                        x: w * 0.440, y: h * 0.533,
                        phaseDelay: 0.8
                    )

                    FloatingEmotionImage(
                        name: "emotion_fiere",
                        width: w * 0.611, baseRotation: -20.31,
                        x: w * 0.151, y: h * 0.728,
                        phaseDelay: 1.2
                    )

                    FloatingEmotionImage(
                        name: "emotion_stresse",
                        width: w * 0.546, baseRotation: 18.27,
                        x: w * 0.865, y: h * 0.711,
                        phaseDelay: 0.6
                    )
                }

                // -- Backdrop blur + gradient fade (Figma 393x305 pinned bottom) --
                VStack {
                    Spacer()
                    ZStack {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .opacity(0.65)

                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 0.85, green: 0.85, blue: 0.85).opacity(0), location: 0.00),
                                Gradient.Stop(color: .white.opacity(0.5), location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                    }
                    .frame(width: w, height: 305)
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.0),
                                .init(color: .black, location: 0.55),
                                .init(color: .black, location: 1.0),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)

                // -- Header + Auth section --
                VStack(spacing: 0) {
                    // Header (top 66pt dans Figma)
                    VStack(spacing: 16) {
                        Text("On fait\nconnaissance ?")
                            .font(.kokoraDisplay(min(w * 0.102, 42), weight: .semibold))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)

                        Text("Tes émotions méritent un endroit à elles.")
                            .font(.kokoraDisplay(min(w * 0.041, 16), weight: .regular))
                            .foregroundStyle(Color(red: 0, green: 0.663, blue: 0.2)) // #00A933
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, h * 0.077) // 66/852

                    Spacer()

                    // Auth section
                    VStack(spacing: 12) {
                        // Apple — SignInWithAppleButton natif avec nonce pour Supabase
                        SignInWithAppleButton(.signIn) { request in
                            let nonce = randomNonceString()
                            currentAppleNonce = nonce
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = sha256(nonce)
                        } onCompletion: { result in
                            handleAppleSignIn(result)
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 58)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                        // Google + Email row (54pt)
                        HStack(spacing: 10) {
                            // Google — stub alert (SDK pas encore branché)
                            Button {
                                Haptics.light()
                                showGoogleAlert = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image("logo_google")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 18, height: 18)
                                    Text("Google")
                                        .font(.kokoraDisplay(14, weight: .semibold))
                                        .foregroundStyle(Color(red: 0.122, green: 0.122, blue: 0.122))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color(red: 0.878, green: 0.878, blue: 0.878), lineWidth: 1.5)
                                )
                            }

                            // Email — ouvre le formulaire modal
                            Button {
                                Haptics.light()
                                showEmailSheet = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "envelope")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("Email")
                                        .font(.kokoraDisplay(14, weight: .semibold))
                                }
                                .foregroundStyle(Color(red: 0.059, green: 0.059, blue: 0.059))
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color.clear)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(Color(red: 0.831, green: 0.831, blue: 0.831), lineWidth: 1.5)
                                )
                            }
                        }

                        // Legal
                        Text("En continuant, tu acceptes nos CGU et notre politique de confidentialité.")
                            .font(.kokoraDisplay(11, weight: .regular))
                            .foregroundStyle(Color(red: 0.533, green: 0.533, blue: 0.533))
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .padding(.horizontal, 20)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                }
            }
        }
    }

    // MARK: - Step 3: First Question

    private var firstQuestionStep: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Aujourd'hui, qu'est-ce qui t'a manqué ?")
                .font(.custom("CrimsonPro-Italic", size: 26, relativeTo: .title))
                .italic()
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.mdTextBlack)
                .padding(.horizontal, 32)

            TextEditor(text: $viewModel.firstAnswer)
                .frame(height: 120)
                .padding(12)
                .scrollContentBackground(.hidden)
                .background(Color.mdBgSubtle)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 32)

            Spacer()

            nextButton
        }
    }

    // MARK: - Step 4: Reformulation

    private var reformulationStep: some View {
        VStack(spacing: 32) {
            Spacer()

            EmotionBubble(
                emotion: .confus,
                text: viewModel.reformulationText,
                size: .large,
                style: .emotional
            )

            Spacer()

            Button {
                viewModel.goNext()
            } label: {
                Text("Continuer")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.mdGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Step 5: First Square

    private var firstSquareStep: some View {
        VStack(spacing: 32) {
            Spacer()

            // Mini heatmap avec un seul carré allumé
            VStack(spacing: 16) {
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.mdOrange)
                        .frame(width: 24, height: 24)

                    ForEach(0..<6, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.mdBorder)
                            .frame(width: 24, height: 24)
                    }
                }
            }

            EmotionBubble(
                emotion: .heureux,
                text: "Jour 1. Reviens demain.",
                size: .medium,
                style: .standard
            )

            Spacer()

            nextButton
        }
    }

    // MARK: - Step 6: Reminders

    private var remindersStep: some View {
        VStack(spacing: 24) {
            Spacer()

            EmotionBubble(
                emotion: .calme,
                text: "Je t'enverrai un signe quand c'est l'heure.",
                size: .medium,
                style: .standard
            )

            VStack(spacing: 20) {
                // Start hour
                VStack(spacing: 8) {
                    HStack {
                        Text("À partir de")
                        Spacer()
                        Text("\(viewModel.notificationStartHour)h00")
                            .fontWeight(.bold)
                    }
                    Slider(value: Binding(
                        get: { Double(viewModel.notificationStartHour) },
                        set: { viewModel.notificationStartHour = Int($0) }
                    ), in: 6...22, step: 1)
                    .tint(Color.mdGreen)
                }

                // End hour
                VStack(spacing: 8) {
                    HStack {
                        Text("Jusqu'à")
                        Spacer()
                        Text("\(viewModel.notificationEndHour)h00")
                            .fontWeight(.bold)
                    }
                    Slider(value: Binding(
                        get: { Double(viewModel.notificationEndHour) },
                        set: { viewModel.notificationEndHour = Int($0) }
                    ), in: Double(viewModel.notificationStartHour + 1)...23, step: 1)
                    .tint(Color.mdGreen)
                }

                // Count
                Stepper(
                    "\(viewModel.notificationCount) rappel\(viewModel.notificationCount > 1 ? "s" : "") par jour",
                    value: $viewModel.notificationCount,
                    in: 1...5
                )
            }
            .padding(20)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.mdBgSubtle)
            }
            .padding(.horizontal, 20)

            Spacer()

            nextButton
        }
    }

    // MARK: - Step 7: Trial

    private var trialStep: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.mdYellow)

            Text("7 jours pour voir si ça te parle.")
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.mdTextBlack)

            Text("Pas de carte bancaire.")
                .font(.subheadline)
                .foregroundStyle(Color.mdTextGray)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    Task {
                        await StoreKitService.shared.purchase()
                    }
                    viewModel.goNext()
                } label: {
                    Text("Essayer gratuitement")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.mdGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }

                Button {
                    viewModel.goNext()
                } label: {
                    Text("Continuer sans abonnement")
                        .font(.subheadline)
                        .foregroundStyle(Color.mdTextGray)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Step 8: Account

    private var accountStep: some View {
        VStack(spacing: 32) {
            Spacer()

            EmotionBubble(
                emotion: .heureux,
                text: "Pour ne rien perdre, crée ton espace.",
                size: .large,
                style: .standard
            )

            VStack(spacing: 16) {
                // NB : depuis le refactor Supabase, l'auth se fait au step .login
                // en début d'onboarding. Cet écran n'est plus qu'une confirmation.
                // Il sera probablement supprimé bientôt (décision utilisateur).
                Button {
                    viewModel.complete(context: modelContext, appState: appState)
                } label: {
                    Text("C'est parti")
                        .font(.kokoraDisplay(18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(Color(red: 0.059, green: 0.059, blue: 0.059))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(.horizontal, 32)
            }

            Spacer()

            Button {
                viewModel.complete(context: modelContext, appState: appState)
            } label: {
                Text("Commencer")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.mdGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Reusable Next Button

    private var nextButton: some View {
        Button {
            viewModel.goNext()
        } label: {
            Text("Suivant")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(viewModel.canGoNext ? Color.mdGreen : Color.mdBorder)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .disabled(!viewModel.canGoNext)
        .padding(.horizontal, 32)
        .padding(.bottom, 40)
    }
}

// MARK: - Floating emotion illustration
// Wrapper décoratif utilisé dans welcomeStep : applique un léger flottement
// (offset Y + micro-rotation) en boucle, avec un délai de phase configurable
// pour désynchroniser les illustrations entre elles.
private struct FloatingEmotionImage: View {
    let name: String
    let width: CGFloat
    let baseRotation: Double
    let x: CGFloat
    let y: CGFloat
    let phaseDelay: Double

    @State private var animate = false

    private let floatAmplitude: CGFloat = 8
    private let rotationWiggle: Double = 2.5
    private let duration: Double = 3.8

    var body: some View {
        Image(name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width)
            .rotationEffect(.degrees(baseRotation + (animate ? rotationWiggle : -rotationWiggle)))
            .offset(y: animate ? -floatAmplitude : floatAmplitude)
            .position(x: x, y: y)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(phaseDelay)
                ) {
                    animate = true
                }
            }
    }
}
