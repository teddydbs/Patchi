import SwiftUI

struct PatchiSpeechBubble: View {
    let text: String
    var style: BubbleStyle = .standard
    var animated: Bool = true

    @State private var visibleCharacters: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Bulle
            Text(displayedText)
                .font(.custom("CrimsonPro-Italic", size: style.fontSize, relativeTo: .title3))
                .italic()
                .multilineTextAlignment(.center)
                .foregroundStyle(style.textColor)
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(style.backgroundColor)
                        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
                }

            // Pointe de la bulle
            Triangle()
                .fill(style.backgroundColor)
                .frame(width: 16, height: 10)
                .rotationEffect(.degrees(180))
                .offset(y: -1)
        }
        .onAppear {
            if animated {
                animateText()
            } else {
                visibleCharacters = text.count
            }
        }
        .onChange(of: text) {
            visibleCharacters = 0
            if animated {
                animateText()
            } else {
                visibleCharacters = text.count
            }
        }
    }

    private var displayedText: String {
        if !animated || visibleCharacters >= text.count {
            return text
        }
        let index = text.index(text.startIndex, offsetBy: min(visibleCharacters, text.count))
        return String(text[..<index])
    }

    private func animateText() {
        visibleCharacters = 0
        let totalChars = text.count
        for i in 0..<totalChars {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.035) {
                withAnimation(.easeOut(duration: 0.05)) {
                    visibleCharacters = i + 1
                }
            }
        }
    }

    enum BubbleStyle {
        case standard       // Bulle blanche classique
        case emotional      // Fond coloré selon l'humeur
        case subtle         // Très discret, pour les petites phrases

        var backgroundColor: Color {
            switch self {
            case .standard: .white
            case .emotional: Color.patchiOrange.opacity(0.12)
            case .subtle: Color(.systemGray6)
            }
        }

        var textColor: Color {
            switch self {
            case .standard: Color(red: 0.2, green: 0.2, blue: 0.2)
            case .emotional: Color(red: 0.15, green: 0.15, blue: 0.15)
            case .subtle: .secondary
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .standard: 18
            case .emotional: 20
            case .subtle: 15
            }
        }
    }
}

// MARK: - Triangle Shape

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Patchi avec bulle combinés

struct PatchiWithBubble: View {
    let expression: PatchiExpression
    let text: String
    var patchiSize: PatchiSize = .medium
    var bubbleStyle: PatchiSpeechBubble.BubbleStyle = .standard

    var body: some View {
        VStack(spacing: 8) {
            PatchiSpeechBubble(
                text: text,
                style: bubbleStyle
            )

            PatchiView(
                expression: expression,
                size: patchiSize
            )
        }
    }
}

// MARK: - Preview

#Preview("Bulle standard") {
    PatchiWithBubble(
        expression: .waving,
        text: "Salut. Moi c'est Patchi.",
        patchiSize: .large
    )
    .padding()
}

#Preview("Bulle émotionnelle") {
    PatchiWithBubble(
        expression: .thinking,
        text: "Tu veux prendre soin de toi.",
        patchiSize: .medium,
        bubbleStyle: .emotional
    )
    .padding()
}

#Preview("Styles de bulles") {
    VStack(spacing: 30) {
        PatchiSpeechBubble(text: "C'est noté.", style: .standard, animated: false)
        PatchiSpeechBubble(text: "30 jours. Tu avais vu juste ?", style: .emotional, animated: false)
        PatchiSpeechBubble(text: "Reviens demain.", style: .subtle, animated: false)
    }
    .padding()
}
