import Foundation

enum AppTheme: String, Codable, CaseIterable, Identifiable {
    case `default`
    case dark
    case ocean
    case forest
    case sunset

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .default: "Par défaut"
        case .dark: "Sombre"
        case .ocean: "Océan"
        case .forest: "Forêt"
        case .sunset: "Coucher de soleil"
        }
    }
}
