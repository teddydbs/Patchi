import Foundation

enum Emotion: String, Codable, CaseIterable, Identifiable {
    // Positives
    case heureux
    case serein
    case chanceux
    case fiere
    case calme
    case amoureux
    // Neutres / pensives
    case empathique
    case confus
    case surpris
    case nostalgique
    // Tendues
    case embarrasse
    case enerve
    case stresse
    case jaloux
    // Tristes
    case triste
    case seul

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .heureux: "Heureux"
        case .serein: "Serein"
        case .chanceux: "Chanceux"
        case .fiere: "Fier"
        case .calme: "Calme"
        case .amoureux: "Amoureux"
        case .empathique: "Empathique"
        case .confus: "Confus"
        case .surpris: "Surpris"
        case .nostalgique: "Nostalgique"
        case .embarrasse: "Embarrassé"
        case .enerve: "Énervé"
        case .stresse: "Stressé"
        case .jaloux: "Jaloux"
        case .triste: "Triste"
        case .seul: "Seul"
        }
    }

    var icon: String {
        switch self {
        case .heureux: "face.smiling.inverse"
        case .serein: "leaf.fill"
        case .chanceux: "star.fill"
        case .fiere: "crown.fill"
        case .calme: "moon.fill"
        case .amoureux: "heart.fill"
        case .empathique: "hands.sparkles.fill"
        case .confus: "questionmark.circle.fill"
        case .surpris: "sparkles"
        case .nostalgique: "clock.arrow.circlepath"
        case .embarrasse: "eye.slash.fill"
        case .enerve: "flame.fill"
        case .stresse: "exclamationmark.triangle.fill"
        case .jaloux: "eye.trianglebadge.exclamationmark.fill"
        case .triste: "cloud.rain.fill"
        case .seul: "person.fill.questionmark"
        }
    }

    /// Nom de l'asset image Patchi pour cette émotion
    var imageName: String? {
        "emotion_\(rawValue)"
    }
}
