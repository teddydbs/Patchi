import Foundation

enum Verdict: String, Codable, CaseIterable, Identifiable {
    case right
    case partial
    case wrong

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .right: "J'avais raison"
        case .partial: "Partiellement"
        case .wrong: "J'avais tort"
        }
    }

    var icon: String {
        switch self {
        case .right: "checkmark.circle.fill"
        case .partial: "minus.circle.fill"
        case .wrong: "xmark.circle.fill"
        }
    }
}

enum DecisionStatus: String, Codable, CaseIterable {
    case pending
    case reviewed30
    case reviewed90

    var displayName: String {
        switch self {
        case .pending: "En attente"
        case .reviewed30: "Reviewé à J+30"
        case .reviewed90: "Reviewé à J+90"
        }
    }
}
