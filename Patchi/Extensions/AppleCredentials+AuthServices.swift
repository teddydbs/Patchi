import AuthenticationServices
import Foundation

/// Bridge entre `AuthenticationServices` (Apple) et `AppleCredentials`
/// (notre DTO découplé du SDK Supabase). Isolé dans ce fichier pour que
/// `AuthService.swift` n'ait pas à importer `AuthenticationServices`.
extension AppleCredentials {
    /// Extrait les champs utiles du credential Apple. Retourne `nil` si
    /// `identityToken` est absent ou mal formé (cas qu'Apple ne devrait
    /// jamais produire, mais on reste défensif).
    ///
    /// - Parameters:
    ///   - credential: le credential brut retourné par `SignInWithAppleButton`.
    ///   - rawNonce: le nonce en clair passé à `ASAuthorizationAppleIDRequest`
    ///     (Supabase vérifie que le hash correspond à celui dans l'id_token).
    init?(credential: ASAuthorizationAppleIDCredential, rawNonce: String) {
        guard
            let identityTokenData = credential.identityToken,
            let idToken = String(data: identityTokenData, encoding: .utf8)
        else {
            return nil
        }

        let givenName = credential.fullName?.givenName?.trimmed
        self.init(
            idToken: idToken,
            rawNonce: rawNonce,
            givenName: (givenName?.isEmpty == false) ? givenName : nil
        )
    }
}
