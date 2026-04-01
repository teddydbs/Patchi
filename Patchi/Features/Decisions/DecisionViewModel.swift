import SwiftUI
import SwiftData

@Observable
final class DecisionViewModel {
    // MARK: - Form

    var title: String = ""
    var context: String = ""
    var prediction: String = ""
    var decision: String = ""
    var importance: Int = 3

    // MARK: - State

    var isCompleted = false

    // MARK: - Computed

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !decision.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Actions

    func save(context modelContext: ModelContext) {
        Haptics.success()
        let newDecision = Decision(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            context: context.trimmingCharacters(in: .whitespacesAndNewlines),
            prediction: prediction.trimmingCharacters(in: .whitespacesAndNewlines),
            decision: decision.trimmingCharacters(in: .whitespacesAndNewlines),
            importance: importance
        )

        modelContext.insert(newDecision)

        // Scheduler les notifications J+30 et J+90
        NotificationService.shared.scheduleDecisionReminder(
            decisionId: newDecision.id,
            title: newDecision.title,
            at: newDecision.reviewAt30,
            type: .j30
        )
        NotificationService.shared.scheduleDecisionReminder(
            decisionId: newDecision.id,
            title: newDecision.title,
            at: newDecision.reviewAt90,
            type: .j90
        )

        // Rappel 2 jours avant chaque verdict
        NotificationService.shared.scheduleDecisionApproaching(
            decisionId: newDecision.id,
            title: newDecision.title,
            verdictDate: newDecision.reviewAt30
        )

        isCompleted = true
    }

    func reset() {
        title = ""
        context = ""
        prediction = ""
        decision = ""
        importance = 3
        isCompleted = false
    }
}
