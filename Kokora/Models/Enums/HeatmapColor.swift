import SwiftUI

enum HeatmapColor: String, Codable, CaseIterable {
    case red
    case orange
    case lightGreen
    case darkGreen

    var color: Color {
        switch self {
        case .red: Color(red: 0.92, green: 0.27, blue: 0.27)
        case .orange: Color(red: 1.0, green: 0.6, blue: 0.2)
        case .lightGreen: Color(red: 0.4, green: 0.8, blue: 0.4)
        case .darkGreen: Color(red: 0.15, green: 0.65, blue: 0.3)
        }
    }

    var label: String {
        switch self {
        case .red: "Raison non valable"
        case .orange: "Raison valable, non réalisé"
        case .lightGreen: "Accompli avec effort"
        case .darkGreen: "Accompli facilement"
        }
    }
}
