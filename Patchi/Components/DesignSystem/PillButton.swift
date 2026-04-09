import SwiftUI

struct PillButton: View {
    let title: String
    var icon: String? = nil
    var style: PillButtonStyle = .primary
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            Haptics.medium()
            action()
        } label: {
            HStack(spacing: DS.Spacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(.body.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: DS.buttonHeight)
            .foregroundStyle(style.foregroundColor)
            .background(style.backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.button, style: .continuous))
            .clayShadow(color: style.shadowColor)
        }
        .buttonStyle(SpringPressStyle())
    }
}

// MARK: - Styles

enum PillButtonStyle {
    case primary
    case secondary
    case mood(Int)
    case destructive
    /// CTA noir plat pour les sheets d'onboarding (ex: FirstNameFallbackView).
    case dark

    var foregroundColor: Color {
        switch self {
        case .primary: .white
        case .secondary: .dsTextPrimary
        case .mood(let score): Color.moodText(score: score)
        case .destructive: .white
        case .dark: .white
        }
    }

    var shadowColor: Color {
        switch self {
        case .primary: .patchiOrange
        case .secondary: .black
        case .mood(let score): Color.mood(score: score)
        case .destructive: .dsDestructive
        case .dark: .black
        }
    }

    @ViewBuilder
    var backgroundView: some View {
        switch self {
        case .primary:
            LinearGradient(
                colors: [.patchiOrange, .patchiOrange.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            Color.dsCard
        case .mood(let score):
            Color.mood(score: score)
        case .destructive:
            Color.dsDestructive
        case .dark:
            Color.mdTextBlack
        }
    }
}

// MARK: - Spring Press Effect

struct SpringPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? DS.pressScale : 1)
            .animation(DS.Animation.press, value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview("PillButton Styles") {
    VStack(spacing: 16) {
        PillButton(title: "Commencer", icon: "arrow.right") {}
        PillButton(title: "Secondaire", style: .secondary) {}
        PillButton(title: "Humeur", style: .mood(4)) {}
        PillButton(title: "Supprimer", icon: "trash", style: .destructive) {}
    }
    .padding(20)
    .background(Color.dsBackground)
}
