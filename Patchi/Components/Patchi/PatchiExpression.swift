import SwiftUI

enum PatchiExpression: String, CaseIterable, Identifiable {
    // Positives
    case happy
    case excited
    case proud
    case grateful
    case celebrating
    case calm

    // Neutres
    case neutral
    case thinking
    case curious
    case waving
    case sleeping

    // Négatives
    case sad
    case tired
    case worried
    case stressed
    case angry
    case surprised
    case nostalgic
    case comforting
    case determined

    var id: String { rawValue }

    /// Nom d'asset dans xcassets (pour les vrais visuels Patchi)
    var assetName: String {
        "patchi_\(rawValue)"
    }

    /// SF Symbol de fallback tant que les assets ne sont pas intégrés
    var fallbackSymbol: String {
        switch self {
        case .happy: "face.smiling.inverse"
        case .excited: "star.circle.fill"
        case .proud: "hands.clap.fill"
        case .grateful: "heart.fill"
        case .celebrating: "party.popper.fill"
        case .calm: "leaf.fill"
        case .neutral: "circle.fill"
        case .thinking: "brain.head.profile.fill"
        case .curious: "eye.fill"
        case .waving: "hand.wave.fill"
        case .sleeping: "moon.zzz.fill"
        case .sad: "cloud.rain.fill"
        case .tired: "battery.0percent"
        case .worried: "exclamationmark.triangle.fill"
        case .stressed: "bolt.heart.fill"
        case .angry: "flame.fill"
        case .surprised: "eyes.inverse"
        case .nostalgic: "clock.arrow.circlepath"
        case .comforting: "hand.raised.fill"
        case .determined: "figure.walk"
        }
    }

    /// Couleur d'accent associée à l'expression
    var accentColor: Color {
        switch self {
        case .happy, .excited, .celebrating: .yellow
        case .proud, .grateful: .pink
        case .calm: .mint
        case .neutral, .thinking, .curious, .waving: .patchiOrange
        case .sleeping, .tired: .indigo
        case .sad, .nostalgic: .blue
        case .worried, .stressed: .orange
        case .angry: .red
        case .surprised: .purple
        case .comforting: .teal
        case .determined: .green
        }
    }

    /// Expression Patchi adaptée au score d'humeur
    static func fromMoodScore(_ score: Int) -> PatchiExpression {
        switch score {
        case 1: .sad
        case 2: .worried
        case 3: .neutral
        case 4: .happy
        case 5: .excited
        default: .neutral
        }
    }

    /// Expression adaptée au contexte
    static func forContext(_ context: PatchiContext) -> PatchiExpression {
        switch context {
        case .onboardingWelcome: .waving
        case .onboardingQuestion: .curious
        case .reformulation: .thinking
        case .checkInComplete: .happy
        case .verdictReveal: .determined
        case .letterDelivery: .excited
        case .sundayRitual: .calm
        case .badDay: .comforting
        case .streak: .celebrating
        case .insight: .proud
        case .idle: .neutral
        case .sleeping: .sleeping
        }
    }
}

enum PatchiContext {
    case onboardingWelcome
    case onboardingQuestion
    case reformulation
    case checkInComplete
    case verdictReveal
    case letterDelivery
    case sundayRitual
    case badDay
    case streak
    case insight
    case idle
    case sleeping
}
