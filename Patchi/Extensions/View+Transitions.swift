import SwiftUI

extension View {
    /// Animation spring micro-interaction (boutons, toggles)
    func springMicro<V: Equatable>(value: V) -> some View {
        self.animation(DS.Animation.micro, value: value)
    }

    /// Animation spring transition d'ecran
    func springScreen<V: Equatable>(value: V) -> some View {
        self.animation(DS.Animation.screen, value: value)
    }

    /// Animation de respiration pour Patchi (clay bounce)
    func breathingAnimation(isAnimating: Bool) -> some View {
        self.offset(y: isAnimating ? -4 : 4)
            .animation(
                .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                value: isAnimating
            )
    }

    /// Reduced motion aware animation
    @ViewBuilder
    func safeAnimation<V: Equatable>(_ animation: Animation, value: V) -> some View {
        if UIAccessibility.isReduceMotionEnabled {
            self
        } else {
            self.animation(animation, value: value)
        }
    }
}

extension AnyTransition {
    /// Transition mot par mot pour les reformulations
    static var wordByWord: AnyTransition {
        .opacity.combined(with: .scale(scale: 0.95))
    }

    /// Transition de carte (slide + fade)
    static var card: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    /// Transition clay (scale + spring)
    static var clay: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.85).combined(with: .opacity),
            removal: .scale(scale: 0.95).combined(with: .opacity)
        )
    }
}
