import SwiftUI

extension View {
    /// Transition lente et organique style Patchi (400-600ms)
    func patchiTransition() -> some View {
        self.animation(.easeInOut(duration: 0.5), value: UUID())
    }

    /// Animation douce pour les changements de couleur d'humeur
    func moodColorAnimation() -> some View {
        self.animation(.easeInOut(duration: 0.4), value: UUID())
    }

    /// Animation de respiration pour Patchi
    func breathingAnimation(isAnimating: Bool) -> some View {
        self.offset(y: isAnimating ? -4 : 4)
            .animation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                value: isAnimating
            )
    }
}

extension AnyTransition {
    /// Transition mot par mot pour les reformulations
    static var wordByWord: AnyTransition {
        .opacity.combined(with: .scale(scale: 0.95))
    }

    /// Transition de carte pour les entrées du journal
    static var card: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }
}
