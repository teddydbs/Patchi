import Foundation
import SwiftData

@Model
final class AccountabilityEntry {
    @Attribute(.unique) var id: UUID
    var date: Date
    var missedAction: String
    var reason: String?
    var isReasonValid: Bool?
    var importance: Int
    var heatmapColorRaw: String
    var isSkipped: Bool

    var heatmapColor: HeatmapColor {
        get { HeatmapColor(rawValue: heatmapColorRaw) ?? .red }
        set { heatmapColorRaw = newValue.rawValue }
    }

    init(
        date: Date = Date(),
        missedAction: String,
        reason: String? = nil,
        isReasonValid: Bool? = nil,
        importance: Int = 3,
        heatmapColor: HeatmapColor = .red,
        isSkipped: Bool = false
    ) {
        self.id = UUID()
        self.date = date
        self.missedAction = missedAction
        self.reason = reason
        self.isReasonValid = isReasonValid
        self.importance = min(max(importance, 1), 5)
        self.heatmapColorRaw = heatmapColor.rawValue
        self.isSkipped = isSkipped
    }

    /// Crée une entrée "skip positif" — tout allait bien
    static func skipEntry(date: Date = Date()) -> AccountabilityEntry {
        AccountabilityEntry(
            date: date,
            missedAction: "",
            importance: 3,
            heatmapColor: .darkGreen,
            isSkipped: true
        )
    }
}
