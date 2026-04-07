import SwiftUI
import SwiftData

@Observable
final class VerdictViewModel {
    // MARK: - Input

    var selectedVerdict: Verdict?
    var whatHappened: String = ""

    // MARK: - State

    var isRevealed = false
    var isSaved = false

    // MARK: - Actions

    func saveVerdict(decision: Decision, verdictType: DecisionReminderType) {
        guard !isSaved else { return }
        guard let verdict = selectedVerdict else { return }
        let text = whatHappened.trimmingCharacters(in: .whitespacesAndNewlines)

        if verdictType == .j30 {
            decision.verdict30 = verdict
            decision.whatHappened30 = text.isEmpty ? nil : text
            decision.status = .reviewed30
        } else {
            decision.verdict90 = verdict
            decision.whatHappened90 = text.isEmpty ? nil : text
            decision.status = .reviewed90
        }

        withAnimation {
            isSaved = true
        }
    }

    // MARK: - Completion

    var completionExpression: PatchiExpression {
        switch selectedVerdict {
        case .right: .celebrating
        case .partial: .thinking
        case .wrong: .comforting
        case nil: .neutral
        }
    }

    var completionPhrase: String {
        switch selectedVerdict {
        case .right: "Tu avais vu juste. Fais-toi confiance."
        case .partial: "Pas tout à fait, mais tu apprends. C'est ça qui compte."
        case .wrong: "Hé. C'est ok. Chaque erreur est une leçon."
        case nil: "C'est noté."
        }
    }
}
