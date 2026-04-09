import SwiftUI
import SwiftData

@Observable
final class AccountabilityViewModel {
    // MARK: - Input

    var missedAction: String = ""
    var reason: String = ""
    var isReasonValid: Bool? = nil
    var importance: Int = 3

    // MARK: - State

    var isCompleted = false
    var showConfirmation = false
    var hasMissedYesterday = false
    var yesterdayDate: Date?

    // MARK: - Computed

    var canSave: Bool { !missedAction.isBlank }

    var heatmapColor: HeatmapColor {
        guard let valid = isReasonValid else { return .orange }
        if valid {
            return .orange  // Raison valable mais non réalisé
        } else {
            return .red     // Raison non valable
        }
    }

    // MARK: - Actions

    /// Sauvegarde une entrée accountability normale
    func save(context: ModelContext) {
        let entry = AccountabilityEntry(
            missedAction: missedAction.trimmed,
            reason: reason.isEmpty ? nil : reason.trimmed,
            isReasonValid: isReasonValid,
            importance: importance,
            heatmapColor: heatmapColor
        )
        context.insert(entry)
        isCompleted = true
        showConfirmation = true
    }

    /// Sauvegarde un skip positif ("Aujourd'hui tout allait bien")
    func saveSkip(context: ModelContext) {
        let entry = AccountabilityEntry.skipEntry()
        context.insert(entry)
        isCompleted = true
        showConfirmation = true
    }

    /// Sauvegarde le rattrapage d'hier
    func saveYesterdayCatchUp(context: ModelContext) {
        guard let yesterday = yesterdayDate else { return }
        let entry = AccountabilityEntry(
            date: yesterday,
            missedAction: missedAction.trimmed,
            reason: reason.isEmpty ? nil : reason,
            isReasonValid: isReasonValid,
            importance: importance,
            heatmapColor: heatmapColor
        )
        context.insert(entry)
        hasMissedYesterday = false
        reset()
    }

    /// Vérifie si hier a été raté
    func checkYesterday(entries: [AccountabilityEntry]) {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date()))!
        let hasYesterday = entries.contains { calendar.isDate($0.date, inSameDayAs: yesterday) }
        if !hasYesterday {
            hasMissedYesterday = true
            yesterdayDate = yesterday
        }
    }

    func reset() {
        missedAction = ""
        reason = ""
        isReasonValid = nil
        importance = 3
        isCompleted = false
        showConfirmation = false
    }
}
