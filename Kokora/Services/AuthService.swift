import Foundation
import GoogleSignIn
import Observation
import OSLog
import Supabase
import SwiftData
import UIKit

private let logger = Logger(subsystem: "com.kokora.app", category: "Auth")

/// Service central d'authentification basé sur **Supabase Auth**.
///
/// Gère :
/// - Sign in with Apple (via `signInWithIdToken` côté Supabase)
/// - Email + mot de passe (sign up / sign in / reset)
/// - Restauration de la session au lancement de l'app
/// - Sync du profile `public.profiles` avec le `User` SwiftData local
///
/// Le service est un singleton `@Observable` : les vues peuvent s'abonner à
/// `isSignedIn`, `currentUserId`, `currentFirstName` pour réagir automatiquement.
@Observable
@MainActor
final class AuthService {
    static let shared = AuthService()

    // MARK: - État observable

    /// Session d'authentification active. Unique source de vérité pour
    /// `isSignedIn` / `currentUserId` / `currentEmail` — évite les bugs où
    /// les 3 flags se désynchronisent entre eux.
    private(set) var authSession: AuthSession?

    /// Profil récupéré depuis la table `public.profiles`. `nil` tant que le
    /// fetch post-login n'a pas eu lieu (ou a échoué).
    private(set) var profile: ProfileState?

    /// `true` si une session Supabase est active.
    var isSignedIn: Bool { authSession != nil }

    /// UUID du user connecté.
    var currentUserId: UUID? { authSession?.userId }

    /// Email du user connecté.
    var currentEmail: String? { authSession?.email }

    /// Prénom lu depuis `profiles.first_name`. Chaîne vide si profil pas encore chargé.
    var currentFirstName: String { profile?.firstName ?? "" }

    /// Flag `profiles.onboarding_completed`. Utilisé par OnboardingView pour
    /// bypasser les étapes restantes quand un user existant se reconnecte.
    var currentProfileOnboardingCompleted: Bool { profile?.onboardingCompleted ?? false }

    /// Erreur publique pour affichage dans l'UI (alert, etc.).
    var lastError: String?

    /// Indique qu'un flow d'auth est en cours (pour désactiver les boutons).
    var isAuthenticating: Bool = false

    // MARK: - Init

    private let client = Supa.shared

    private init() {
        Task { await self.bootstrap() }
    }

    /// Le stream `authStateChanges` émet un événement `.initialSession` dès l'abonnement
    /// avec la session persistée — inutile d'appeler `handleSessionChange` manuellement,
    /// ça provoquerait un double fetch du profile au démarrage.
    private func bootstrap() async {
        for await (event, session) in client.auth.authStateChanges {
            await self.handleAuthEvent(event: event, session: session)
        }
    }

    private func handleAuthEvent(event: AuthChangeEvent, session: Session?) async {
        switch event {
        case .initialSession, .signedIn, .userUpdated:
            if let session {
                await self.applySession(session, fetchProfile: true)
            } else {
                self.clearSessionState()
            }
        case .tokenRefreshed:
            // Le token a changé mais l'utilisateur est le même — on met à jour
            // la session légère sans refetcher le profile (déjà en mémoire).
            if let session {
                self.authSession = AuthSession(from: session)
            }
        case .signedOut:
            self.clearSessionState()
        default:
            break
        }
    }

    private func clearSessionState() {
        self.authSession = nil
        self.profile = nil
    }

    private func applySession(_ session: Session, fetchProfile: Bool) async {
        self.authSession = AuthSession(from: session)

        guard fetchProfile else { return }

        // Le profile est auto-créé par le trigger `on_auth_user_created` ;
        // juste après signup il peut ne pas exister encore — on réessaiera
        // au prochain événement d'auth.
        do {
            let row: ProfileRow = try await client
                .from("profiles")
                .select()
                .eq("id", value: session.user.id)
                .single()
                .execute()
                .value
            self.profile = ProfileState(
                firstName: row.firstName,
                onboardingCompleted: row.onboardingCompleted
            )
        } catch {
            logger.warning("Could not fetch profile: \(error.localizedDescription, privacy: .public)")
        }
    }

    /// Exécute une opération d'auth en gérant le flag `isAuthenticating`.
    /// Centralise le pattern `true / defer { false }` qui était dupliqué sur
    /// chaque méthode publique d'auth. `@discardableResult` car certaines
    /// méthodes (signOut, deleteAccount) ignorent la valeur de retour.
    @discardableResult
    private func authenticating<T>(_ operation: () async throws -> T) async throws -> T {
        isAuthenticating = true
        defer { isAuthenticating = false }
        return try await operation()
    }

    // MARK: - Sign in with Apple

    /// Authentifie l'utilisateur auprès de Supabase à partir d'un
    /// `ASAuthorizationAppleIDCredential` obtenu côté client.
    ///
    /// - Parameters:
    ///   - credential: le credential retourné par `SignInWithAppleButton`
    ///   - rawNonce: le nonce en clair passé à `ASAuthorizationAppleIDRequest`
    ///     (Supabase vérifie que le hash correspond à celui dans l'id_token).
    /// - Returns: le prénom extrait du credential (si fourni par Apple).
    @discardableResult
    func signInWithApple(_ credentials: AppleCredentials) async throws -> String? {
        try await authenticating {
            _ = try await client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .apple,
                    idToken: credentials.idToken,
                    nonce: credentials.rawNonce
                )
            )
        }

        // Si Apple a fourni un prénom (1er sign-in), on le persiste dans le profile.
        // updateProfile met à jour `self.profile` — pas besoin de le faire ici.
        if let givenName = credentials.givenName, !givenName.isEmpty, let userId = currentUserId {
            try await updateProfile(userId: userId, firstName: givenName)
        }

        return credentials.givenName
    }

    // MARK: - Sign in with Google

    /// Authentifie l'utilisateur via le SDK natif `GoogleSignIn`.
    ///
    /// Flow :
    /// 1. Présente le sheet natif Google (géré par le SDK)
    /// 2. Récupère l'`idToken` du user depuis `GIDSignInResult`
    /// 3. L'envoie à Supabase via `signInWithIdToken(provider: .google)`
    /// 4. Si Google a fourni un prénom, le persiste dans `profiles.first_name`
    ///
    /// ⚠️ Requiert que "Skip nonce checks" soit ON côté Supabase Google provider,
    /// car le SDK GoogleSignIn iOS n'expose pas le nonce au token endpoint.
    ///
    /// - Returns: le prénom fourni par Google si présent, `nil` sinon.
    @discardableResult
    func signInWithGoogle() async throws -> String? {
        guard let presentingVC = Self.topViewController() else {
            throw AuthError.noPresentingViewController
        }

        return try await authenticating {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC)

            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.missingIdentityToken
            }

            _ = try await client.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .google,
                    idToken: idToken
                )
            )

            let givenName = result.user.profile?.givenName?.trimmingCharacters(in: .whitespaces)

            if let givenName, !givenName.isEmpty, let userId = currentUserId {
                try await updateProfile(userId: userId, firstName: givenName)
            }

            return (givenName?.isEmpty == false) ? givenName : nil
        }
    }

    /// Remonte jusqu'au view controller le plus en avant pour servir de
    /// context de présentation au sheet GoogleSignIn.
    private static func topViewController() -> UIViewController? {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })
        else { return nil }

        var topVC = window.rootViewController
        while let presented = topVC?.presentedViewController {
            topVC = presented
        }
        return topVC
    }

    // MARK: - Email + password

    /// Crée un compte avec email + mot de passe. Le prénom est envoyé dans
    /// `raw_user_meta_data` ce qui permet au trigger `handle_new_user` de
    /// pré-remplir `profiles.first_name` automatiquement.
    func signUpWithEmail(email: String, password: String, firstName: String) async throws {
        try await authenticating {
            _ = try await client.auth.signUp(
                email: email,
                password: password,
                data: ["first_name": .string(firstName)]
            )
        }
    }

    /// Connecte un utilisateur existant avec email + mot de passe.
    func signInWithEmail(email: String, password: String) async throws {
        try await authenticating {
            _ = try await client.auth.signIn(email: email, password: password)
        }
    }

    /// Envoie un email de réinitialisation de mot de passe. Pas d'erreur si
    /// l'email n'existe pas (protection anti-enumeration côté Supabase).
    func resetPassword(email: String) async throws {
        try await authenticating {
            try await client.auth.resetPasswordForEmail(email)
        }
    }

    // MARK: - Profile updates

    /// Met à jour le prénom dans `profiles.first_name` (ex: fallback après
    /// un Sign in with Apple qui n'a pas retourné le nom).
    func updateProfile(userId: UUID, firstName: String) async throws {
        try await client
            .from("profiles")
            .update(ProfilePatch(firstName: firstName))
            .eq("id", value: userId)
            .execute()

        // Mise à jour optimiste de l'état local
        profile = ProfileState(
            firstName: firstName,
            onboardingCompleted: profile?.onboardingCompleted ?? false
        )
    }

    /// Marque le profil de l'utilisateur courant comme "onboarding terminé".
    /// Appelé à la fin de `OnboardingViewModel.complete()` pour qu'un futur
    /// re-login sur un autre device skip directement l'onboarding.
    func markOnboardingCompleted() async throws {
        guard let userId = currentUserId else {
            throw AuthError.noSession
        }
        try await client
            .from("profiles")
            .update(ProfilePatch(onboardingCompleted: true))
            .eq("id", value: userId)
            .execute()

        profile = ProfileState(
            firstName: profile?.firstName ?? "",
            onboardingCompleted: true
        )
    }

    // MARK: - Friendly error messages

    /// Mappe une erreur Supabase/réseau en message user-friendly en français.
    ///
    /// Dispatch en 3 couches, de la plus typée à la moins typée :
    /// 1. `URLError` → problèmes réseau (reconnu par Foundation)
    /// 2. `Supabase.AuthError` → erreurs d'auth typées, avec `ErrorCode` stable côté serveur
    /// 3. Fallback générique — on ne montre JAMAIS le `localizedDescription` brut à l'user
    ///    car il peut contenir des détails techniques non traduits.
    static func friendlyMessage(for error: Error) -> String {
        if let urlError = error as? URLError {
            return message(for: urlError)
        }

        if let authError = error as? Supabase.AuthError {
            return message(for: authError)
        }

        return "Une erreur est survenue. Réessaie dans un instant."
    }

    private static func message(for urlError: URLError) -> String {
        switch urlError.code {
        case .notConnectedToInternet,
             .networkConnectionLost,
             .dataNotAllowed,
             .internationalRoamingOff:
            return "Pas de connexion internet. Vérifie ton réseau."
        case .timedOut:
            return "La requête a pris trop de temps. Réessaie."
        case .cannotFindHost,
             .cannotConnectToHost,
             .dnsLookupFailed,
             .resourceUnavailable:
            return "Impossible de joindre le serveur. Réessaie dans un instant."
        default:
            return "Problème de connexion. Vérifie ton réseau et réessaie."
        }
    }

    private static func message(for authError: Supabase.AuthError) -> String {
        switch authError {
        case .sessionMissing:
            return "Ta session a expiré. Reconnecte-toi."
        case .weakPassword:
            return "Mot de passe trop faible. Utilise au moins 6 caractères."
        case let .api(_, errorCode, _, _):
            return message(for: errorCode)
        default:
            return "Une erreur est survenue. Réessaie dans un instant."
        }
    }

    /// Les `ErrorCode` sont stables côté serveur Supabase — sûrs pour matcher.
    /// Source : https://github.com/supabase/auth/blob/master/internal/api/errorcodes.go
    private static func message(for errorCode: Supabase.ErrorCode) -> String {
        switch errorCode {
        case .emailExists, .userAlreadyExists, .identityAlreadyExists:
            return "Cet email est déjà utilisé. Essaie de te connecter à la place."
        case .invalidCredentials:
            return "Email ou mot de passe incorrect."
        case .emailNotConfirmed:
            return "Ton email n'est pas encore confirmé. Vérifie ta boîte mail."
        case .weakPassword:
            return "Mot de passe trop court (6 caractères minimum)."
        case .userNotFound:
            return "Aucun compte avec cet email. Crée-toi un compte."
        case .overRequestRateLimit,
             .overEmailSendRateLimit,
             .overSMSSendRateLimit:
            return "Trop de tentatives. Réessaie dans quelques minutes."
        case .signupDisabled, .emailProviderDisabled:
            return "La création de compte est temporairement désactivée."
        case .userBanned:
            return "Ce compte est suspendu. Contacte le support."
        case .captchaFailed:
            return "Captcha incorrect. Réessaie."
        case .validationFailed, .badJSON:
            return "Les informations saisies sont invalides."
        case .otpExpired:
            return "Le code a expiré. Demande-en un nouveau."
        case .samePassword:
            return "Ton nouveau mot de passe doit être différent de l'ancien."
        default:
            return "Une erreur est survenue. Réessaie dans un instant."
        }
    }

    // MARK: - Sign out

    func signOut() async throws {
        try await client.auth.signOut()
        // Le handler `authStateChanges` va automatiquement remettre l'état à 0.
    }

    // MARK: - Delete account (RGPD)

    /// Supprime définitivement le compte de l'utilisateur courant via la RPC
    /// Supabase `delete_account()` (migration 002). Cascade delete sur toutes
    /// les tables user-owned (profiles, checkins, decisions, letters, accountability).
    /// Après succès, l'utilisateur est déconnecté automatiquement.
    func deleteAccount() async throws {
        guard isSignedIn else {
            throw AuthError.noSession
        }
        try await authenticating {
            try await client.rpc("delete_account").execute()
        }
        // Le delete en cascade supprime auth.users → la session devient invalide.
        // On force le sign out côté client pour déclencher l'event .signedOut.
        try? await client.auth.signOut()
    }

    // MARK: - Errors

    enum AuthError: LocalizedError {
        case missingIdentityToken
        case noSession
        case noPresentingViewController

        var errorDescription: String? {
            switch self {
            case .missingIdentityToken: return "Impossible de récupérer le token d'authentification."
            case .noSession: return "Aucune session active."
            case .noPresentingViewController: return "Impossible d'ouvrir la fenêtre de connexion."
            }
        }
    }
}

// MARK: - State types

/// Snapshot léger de la session Supabase. Découple AuthService des types
/// Supabase et permet aux call sites d'accéder aux infos de session sans
/// importer le SDK.
struct AuthSession: Equatable {
    let userId: UUID
    let email: String?

    init(userId: UUID, email: String?) {
        self.userId = userId
        self.email = email
    }

    init(from session: Session) {
        self.userId = session.user.id
        self.email = session.user.email
    }
}

/// DTO léger pour transporter les credentials Apple de la vue vers `AuthService`.
/// Découple le service de `AuthenticationServices` (testabilité, mocking).
///
/// La vue extrait les champs du `ASAuthorizationAppleIDCredential` via l'init
/// `init(credential:rawNonce:)` et passe ce struct au service.
struct AppleCredentials: Equatable {
    let idToken: String
    let rawNonce: String
    /// Prénom fourni par Apple uniquement au 1er sign-in, `nil` ensuite.
    let givenName: String?
}

/// État public du profil stocké dans `public.profiles`.
struct ProfileState: Equatable {
    let firstName: String
    let onboardingCompleted: Bool
}

// MARK: - Profile DTOs (Supabase wire format)

/// Row de `public.profiles` pour la désérialisation JSON (snake_case côté DB).
private struct ProfileRow: Decodable {
    let id: UUID
    let firstName: String
    let onboardingCompleted: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case onboardingCompleted = "onboarding_completed"
    }
}

/// Patch partiel de `public.profiles`. Les champs `nil` ne sont pas envoyés
/// (grâce à la stratégie d'encoding par défaut de `JSONEncoder` qui skip
/// les optionnels nil quand on les marque via `encodeIfPresent`).
private struct ProfilePatch: Encodable {
    let firstName: String?
    let onboardingCompleted: Bool?

    init(firstName: String? = nil, onboardingCompleted: Bool? = nil) {
        self.firstName = firstName
        self.onboardingCompleted = onboardingCompleted
    }

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case onboardingCompleted = "onboarding_completed"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(onboardingCompleted, forKey: .onboardingCompleted)
    }
}
