import Foundation

enum Emotion: String, Codable, CaseIterable, Identifiable {
    case heureux
    case beni
    case bien
    case chanceux
    case excite
    case confus
    case ennuye
    case gene
    case partage
    case nostalgique
    case stresse
    case depasse
    case anxieux
    case agite
    case frustre
    case enColere
    case triste
    case decu
    case epuise
    case seul

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .heureux: "Heureux"
        case .beni: "Béni"
        case .bien: "Bien"
        case .chanceux: "Chanceux"
        case .excite: "Excité"
        case .confus: "Confus"
        case .ennuye: "Ennuyé"
        case .gene: "Gêné"
        case .partage: "Partagé"
        case .nostalgique: "Nostalgique"
        case .stresse: "Stressé"
        case .depasse: "Dépassé"
        case .anxieux: "Anxieux"
        case .agite: "Agité"
        case .frustre: "Frustré"
        case .enColere: "En colère"
        case .triste: "Triste"
        case .decu: "Déçu"
        case .epuise: "Épuisé"
        case .seul: "Seul"
        }
    }

    var icon: String {
        switch self {
        case .heureux: "face.smiling.inverse"
        case .beni: "sparkles"
        case .bien: "hand.thumbsup.fill"
        case .chanceux: "star.fill"
        case .excite: "bolt.fill"
        case .confus: "questionmark.circle.fill"
        case .ennuye: "moon.zzz.fill"
        case .gene: "eye.slash.fill"
        case .partage: "arrow.left.arrow.right"
        case .nostalgique: "clock.arrow.circlepath"
        case .stresse: "exclamationmark.triangle.fill"
        case .depasse: "water.waves"
        case .anxieux: "waveform.path.ecg"
        case .agite: "wind"
        case .frustre: "xmark.circle.fill"
        case .enColere: "flame.fill"
        case .triste: "cloud.rain.fill"
        case .decu: "arrow.down.heart.fill"
        case .epuise: "battery.0percent"
        case .seul: "person.fill.questionmark"
        }
    }
}
