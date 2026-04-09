import SwiftUI

extension View {
    /// Exécute `action` après un délai, typiquement pour focaliser un champ
    /// texte juste après la présentation d'une sheet/modal. Sans délai le
    /// TextField refuse souvent le focus car le clavier n'est pas encore prêt.
    ///
    /// Usage :
    /// ```swift
    /// .focusAfter { focusedField = .email }
    /// ```
    func focusAfter(
        _ delay: Duration = .milliseconds(400),
        action: @escaping @MainActor () -> Void
    ) -> some View {
        task {
            try? await Task.sleep(for: delay)
            action()
        }
    }
}
