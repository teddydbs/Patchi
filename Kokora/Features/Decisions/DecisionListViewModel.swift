import SwiftUI

@Observable
final class DecisionListViewModel {
    // MARK: - State

    var selectedFilter: DecisionStatus?
    var selectedDecision: Decision?
    var showVerdict: Bool = false
    var verdictType: DecisionReminderType = .j30

    // MARK: - Filtering

    func filteredDecisions(from decisions: [Decision]) -> [Decision] {
        guard let filter = selectedFilter else { return decisions }
        return decisions.filter { $0.status == filter }
    }

    // MARK: - Verdict Logic

    /// Vérifie si un verdict est dû et ouvre la sheet correspondante
    func handleVerdictTap(for decision: Decision) {
        if decision.status == .pending && decision.reviewAt30 <= Date() {
            selectedDecision = decision
            // Si J+90 aussi passé, proposer directement le J+90 (skip le J+30)
            if decision.reviewAt90 <= Date() {
                verdictType = .j90
            } else {
                verdictType = .j30
            }
            showVerdict = true
        } else if decision.status == .reviewed30 && decision.reviewAt90 <= Date() {
            selectedDecision = decision
            verdictType = .j90
            showVerdict = true
        }
    }
}
