import UIKit

enum Haptics {
    /// Feedback léger — sélection, toggle, tap
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// Feedback medium — action confirmée, bouton principal
    static func medium() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// Feedback succès — check-in sauvé, lettre scellée, verdict enregistré
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Feedback erreur — limite atteinte, action impossible
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    /// Feedback warning — max sélection atteint
    static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    /// Sélection — changement d'étape, navigation
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
