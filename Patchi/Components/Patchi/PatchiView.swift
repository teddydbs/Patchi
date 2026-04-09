import Lottie
import SwiftUI

struct PatchiView: View {
    let expression: PatchiExpression
    var size: PatchiSize = .medium
    var showShadow: Bool = true
    var animated: Bool = true

    @State private var isBreathing = false

    var body: some View {
        patchiBody
            .frame(width: size.dimension, height: size.dimension)
            .offset(y: animated && isBreathing ? -3 : animated ? 3 : 0)
            .animation(
                animated
                    ? .easeInOut(duration: 1.8).repeatForever(autoreverses: true)
                    : nil,
                value: isBreathing
            )
            .shadow(
                color: showShadow ? expression.accentColor.opacity(0.3) : .clear,
                radius: 8,
                y: 4
            )
            .onAppear {
                if animated { isBreathing = true }
            }
    }

    @ViewBuilder
    private var patchiBody: some View {
        if let animation = Self.lottieAnimation(for: expression) {
            LottieView(animation: animation)
                .playing(loopMode: expression.isLooping ? .loop : .playOnce)
        } else if UIImage(named: expression.assetName) != nil {
            Image(expression.assetName)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            PatchiPlaceholder(expression: expression, size: size)
        }
    }

    /// Cache statique des animations Lottie résolues.
    /// Sans ce cache, `LottieAnimation.named(_:)` parse le JSON du bundle à chaque re-render,
    /// ce qui est catastrophique pour la perf vu que PatchiView est utilisé partout
    /// (Home, CheckIn, onboarding, listes). On garde la valeur optionnelle pour
    /// mémoriser aussi les absences et éviter de retaper le disque.
    private static var animationCache: [String: LottieAnimation?] = [:]

    private static func lottieAnimation(for expression: PatchiExpression) -> LottieAnimation? {
        let name = expression.lottieAnimationName
        if let cached = animationCache[name] {
            return cached
        }
        let animation = LottieAnimation.named(name)
        animationCache[name] = animation
        return animation
    }
}

// MARK: - Placeholder (tant que les vrais assets ne sont pas intégrés)

private struct PatchiPlaceholder: View {
    let expression: PatchiExpression
    let size: PatchiSize

    var body: some View {
        ZStack {
            // Corps — patate orange
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 1.0, green: 0.7, blue: 0.3),
                            Color.patchiOrange
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size.dimension * 0.5
                    )
                )
                .frame(width: size.dimension * 0.85, height: size.dimension * 0.9)

            // Visage
            VStack(spacing: size.dimension * 0.03) {
                // Yeux
                HStack(spacing: size.dimension * 0.18) {
                    PatchiEye(expression: expression, size: size)
                    PatchiEye(expression: expression, size: size)
                }

                // Joues rosées
                HStack(spacing: size.dimension * 0.3) {
                    Circle()
                        .fill(Color.pink.opacity(0.35))
                        .frame(width: size.dimension * 0.12)
                    Circle()
                        .fill(Color.pink.opacity(0.35))
                        .frame(width: size.dimension * 0.12)
                }
                .offset(y: -size.dimension * 0.01)

                // Bouche
                PatchiMouth(expression: expression, size: size)
            }
            .offset(y: size.dimension * 0.02)
        }
    }
}

// MARK: - Yeux

private struct PatchiEye: View {
    let expression: PatchiExpression
    let size: PatchiSize

    var body: some View {
        ZStack {
            // Oeil
            Ellipse()
                .fill(.black)
                .frame(width: eyeWidth, height: eyeHeight)

            // Reflet
            Circle()
                .fill(.white)
                .frame(width: size.dimension * 0.04)
                .offset(x: -size.dimension * 0.02, y: -size.dimension * 0.02)
        }
    }

    private var eyeWidth: CGFloat {
        switch expression {
        case .sleeping: size.dimension * 0.1
        case .surprised: size.dimension * 0.12
        case .angry: size.dimension * 0.1
        default: size.dimension * 0.1
        }
    }

    private var eyeHeight: CGFloat {
        switch expression {
        case .sleeping: size.dimension * 0.02  // Yeux fermés
        case .surprised: size.dimension * 0.12 // Grands ouverts
        case .angry: size.dimension * 0.06     // Plissés
        case .happy, .excited, .celebrating: size.dimension * 0.06 // Arc joyeux
        default: size.dimension * 0.1
        }
    }
}

// MARK: - Bouche

private struct PatchiMouth: View {
    let expression: PatchiExpression
    let size: PatchiSize

    var body: some View {
        switch expression {
        case .happy, .excited, .celebrating, .proud, .grateful:
            // Sourire
            MouthArc(isSmile: true)
                .stroke(.black, lineWidth: size.dimension * 0.02)
                .frame(width: size.dimension * 0.15, height: size.dimension * 0.08)

        case .sad, .tired, .worried:
            // Moue
            MouthArc(isSmile: false)
                .stroke(.black, lineWidth: size.dimension * 0.02)
                .frame(width: size.dimension * 0.12, height: size.dimension * 0.06)

        case .surprised:
            // O
            Circle()
                .stroke(.black, lineWidth: size.dimension * 0.02)
                .frame(width: size.dimension * 0.08, height: size.dimension * 0.08)

        case .angry:
            // Trait tendu
            Rectangle()
                .fill(.black)
                .frame(width: size.dimension * 0.12, height: size.dimension * 0.02)

        case .sleeping:
            // Petit trait neutre
            Rectangle()
                .fill(.black)
                .frame(width: size.dimension * 0.08, height: size.dimension * 0.015)
                .cornerRadius(1)

        default:
            // Neutre — petit sourire léger
            MouthArc(isSmile: true)
                .stroke(.black, lineWidth: size.dimension * 0.018)
                .frame(width: size.dimension * 0.1, height: size.dimension * 0.04)
        }
    }
}

// MARK: - Mouth Arc Shape

private struct MouthArc: Shape {
    let isSmile: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        if isSmile {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: rect.width, y: 0),
                control: CGPoint(x: rect.width / 2, y: rect.height)
            )
        } else {
            path.move(to: CGPoint(x: 0, y: rect.height))
            path.addQuadCurve(
                to: CGPoint(x: rect.width, y: rect.height),
                control: CGPoint(x: rect.width / 2, y: 0)
            )
        }
        return path
    }
}

// MARK: - Sizes

enum PatchiSize {
    case small      // Dans les listes, notifications
    case medium     // Dans les cards, check-in
    case large      // Onboarding, moments de vérité
    case hero       // Premier écran onboarding

    var dimension: CGFloat {
        switch self {
        case .small: 44
        case .medium: 80
        case .large: 140
        case .hero: 200
        }
    }
}

// MARK: - Preview

#Preview("Toutes les expressions") {
    ScrollView {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 20) {
            ForEach(PatchiExpression.allCases) { expression in
                VStack(spacing: 8) {
                    PatchiView(expression: expression, size: .medium)
                    Text(expression.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}

#Preview("Tailles") {
    HStack(spacing: 30) {
        PatchiView(expression: .happy, size: .small)
        PatchiView(expression: .happy, size: .medium)
        PatchiView(expression: .happy, size: .large)
    }
}
