import AuthenticationServices
import SwiftUI
import SwiftData

@Observable
final class AuthService {
    static let shared = AuthService()

    var isSignedIn = false
    var userName: String?
    var userEmail: String?

    private let userIdentifierKey = "appleUserIdentifier"

    private init() {
        checkExistingCredential()
    }

    // MARK: - Handle Sign In Result

    func handleSignIn(_ result: Result<ASAuthorization, Error>, context: ModelContext) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }

            let userIdentifier = credential.user
            UserDefaults.standard.set(userIdentifier, forKey: userIdentifierKey)

            // Récupérer le nom et l'email (disponibles uniquement au premier sign in)
            let firstName = credential.fullName?.givenName
            let email = credential.email

            if let firstName {
                userName = firstName
            }
            if let email {
                userEmail = email
            }

            // Mettre à jour ou créer le User dans SwiftData
            let descriptor = FetchDescriptor<User>()
            if let existingUser = try? context.fetch(descriptor).first {
                existingUser.appleUserIdentifier = userIdentifier
                if let email { existingUser.email = email }
            }

            isSignedIn = true

        case .failure(let error):
            print("Sign in with Apple failed: \(error.localizedDescription)")
        }
    }

    // MARK: - Check Existing Credential

    func checkExistingCredential() {
        guard let userIdentifier = UserDefaults.standard.string(forKey: userIdentifierKey) else {
            isSignedIn = false
            return
        }

        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userIdentifier) { [weak self] state, _ in
            DispatchQueue.main.async {
                switch state {
                case .authorized:
                    self?.isSignedIn = true
                case .revoked, .notFound:
                    self?.isSignedIn = false
                    UserDefaults.standard.removeObject(forKey: self?.userIdentifierKey ?? "")
                default:
                    break
                }
            }
        }
    }

    // MARK: - Sign Out

    func signOut() {
        UserDefaults.standard.removeObject(forKey: userIdentifierKey)
        isSignedIn = false
        userName = nil
        userEmail = nil
    }
}

// MARK: - SwiftUI Sign In Button

struct AppleSignInButton: View {
    @Environment(\.modelContext) private var modelContext
    @State private var authService = AuthService.shared

    var body: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            authService.handleSignIn(result, context: modelContext)
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
        .cornerRadius(12)
    }
}
