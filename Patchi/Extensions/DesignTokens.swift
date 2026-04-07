import SwiftUI

// MARK: - Design System Constants

enum DS {

    // MARK: Radii

    enum Radius {
        static let outer: CGFloat = 40
        static let card: CGFloat = 32
        static let button: CGFloat = 20
        static let chip: CGFloat = 16
        static let input: CGFloat = 16
    }

    // MARK: Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let section: CGFloat = 48
    }

    // MARK: Typography sizes

    enum Font {
        static let hero: CGFloat = 48
        static let sectionTitle: CGFloat = 32
        static let cardTitle: CGFloat = 22
        static let body: CGFloat = 17
        static let caption: CGFloat = 13
    }

    // MARK: Shadows (Clay Stack)

    struct ClayShadow: ViewModifier {
        var color: Color = .black

        func body(content: Content) -> some View {
            content
                .shadow(color: color.opacity(0.08), radius: 12, x: 0, y: 8)
                .shadow(color: color.opacity(0.04), radius: 4, x: 0, y: 2)
        }
    }

    // MARK: Animation

    enum Animation {
        static let micro: SwiftUI.Animation = .spring(response: 0.3, dampingFraction: 0.7)
        static let screen: SwiftUI.Animation = .spring(response: 0.5, dampingFraction: 0.85)
        static let press: SwiftUI.Animation = .spring(response: 0.25, dampingFraction: 0.6)
        static let blobDrift: SwiftUI.Animation = .linear(duration: 10).repeatForever(autoreverses: true)
    }

    // MARK: Press Scale

    static let pressScale: CGFloat = 0.92

    // MARK: Button Height

    static let buttonHeight: CGFloat = 56
    static let chipHeight: CGFloat = 36
}

// MARK: - View Modifiers

extension View {
    func clayShadow(color: Color = .black) -> some View {
        modifier(DS.ClayShadow(color: color))
    }

    func clayCard() -> some View {
        self
            .padding(DS.Spacing.lg)
            .background {
                RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                    .fill(Color.dsCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
            .clayShadow()
    }
}
