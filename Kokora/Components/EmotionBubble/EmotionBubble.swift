import SwiftUI

/// Affiche une illustration d'émotion au-dessus d'une bulle de texte.
/// Remplace l'ancien composant mascotte — mêmes usages (onboarding,
/// reformulation, verdict, states vides), sans le personnage Kokora.
struct EmotionBubble: View {
    let emotion: Emotion
    let text: String
    var size: Size = .medium
    var style: Style = .emotional

    enum Size {
        case small, medium, large, hero

        var dimension: CGFloat {
            switch self {
            case .small: 44
            case .medium: 80
            case .large: 140
            case .hero: 200
            }
        }
    }

    enum Style {
        case emotional  // titres, moments forts (italic)
        case standard   // dialogue courant
        case subtle     // hints, aides
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(emotion.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size.dimension, height: size.dimension)

            Text(text)
                .font(textFont)
                .foregroundStyle(textColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    private var textFont: Font {
        switch style {
        case .emotional: .system(size: 20, weight: .medium, design: .serif).italic()
        case .standard: .system(size: 17, weight: .medium)
        case .subtle: .system(size: 14, weight: .regular)
        }
    }

    private var textColor: Color {
        switch style {
        case .emotional, .standard: Color.mdTextBlack
        case .subtle: Color.mdTextGray
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        EmotionBubble(emotion: .heureux, text: "Bienvenue ! Ton journal t'attend.", size: .medium, style: .emotional)
        EmotionBubble(emotion: .confus, text: "30 jours. Tu avais vu juste ?", size: .large, style: .emotional)
        EmotionBubble(emotion: .empathique, text: "C'est noté.", size: .small, style: .standard)
    }
    .padding()
}
