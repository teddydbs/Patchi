import SwiftUI
import SwiftData

struct DecisionListView: View {
    @Query(sort: \Decision.createdAt, order: .reverse) private var decisions: [Decision]
    @State private var selectedFilter: DecisionStatus?
    @State private var selectedDecision: Decision?
    @State private var showVerdict: Bool = false
    @State private var verdictType: DecisionReminderType = .j30

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filtres
                filterBar

                if filteredDecisions.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(filteredDecisions) { decision in
                            DecisionRow(decision: decision) {
                                // Vérifier si un verdict est dû
                                if decision.status == .pending && decision.reviewAt30 <= Date() {
                                    selectedDecision = decision
                                    verdictType = .j30
                                    showVerdict = true
                                } else if decision.status == .reviewed30 && decision.reviewAt90 <= Date() {
                                    selectedDecision = decision
                                    verdictType = .j90
                                    showVerdict = true
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Décisions")
            .sheet(isPresented: $showVerdict) {
                if let decision = selectedDecision {
                    VerdictView(decision: decision, verdictType: verdictType)
                }
            }
        }
    }

    // MARK: - Filters

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterButton(label: "Toutes", count: decisions.count, isSelected: selectedFilter == nil) {
                    selectedFilter = nil
                }
                ForEach(DecisionStatus.allCases, id: \.rawValue) { status in
                    let count = decisions.filter { $0.status == status }.count
                    FilterButton(label: status.displayName, count: count, isSelected: selectedFilter == status) {
                        selectedFilter = status
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private var filteredDecisions: [Decision] {
        guard let filter = selectedFilter else { return decisions }
        return decisions.filter { $0.status == filter }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            PatchiView(expression: .curious, size: .large)
            Text("Aucune décision enregistrée.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Appuie sur + pour en créer une.")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Spacer()
        }
    }
}

// MARK: - Decision Row

private struct DecisionRow: View {
    let decision: Decision
    let onVerdictTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(decision.title)
                    .font(.headline)
                Spacer()
                importanceStars
            }

            Text(decision.decision)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack {
                // Statut
                StatusPill(status: decision.status)

                Spacer()

                // Countdown ou verdict
                if decision.status == .pending {
                    let daysToVerdict = decision.reviewAt30.daysSinceNow
                    if daysToVerdict <= 0 {
                        Button("Donner le verdict") {
                            onVerdictTap()
                        }
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                    } else {
                        Text("J-\(daysToVerdict)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.orange)
                    }
                } else if decision.status == .reviewed30 {
                    if let verdict = decision.verdict30 {
                        Label(verdict.displayName, systemImage: verdict.icon)
                            .font(.caption)
                            .foregroundStyle(verdictColor(verdict))
                    }
                    let daysTo90 = decision.reviewAt90.daysSinceNow
                    if daysTo90 <= 0 {
                        Button("Verdict J+90") {
                            onVerdictTap()
                        }
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.purple)
                    }
                } else if decision.status == .reviewed90 {
                    if let verdict = decision.verdict90 {
                        Label(verdict.displayName, systemImage: verdict.icon)
                            .font(.caption)
                            .foregroundStyle(verdictColor(verdict))
                    }
                }
            }

            Text(decision.createdAt.formattedShort)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    private var importanceStars: some View {
        HStack(spacing: 2) {
            ForEach(0..<decision.importance, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(.orange)
            }
        }
    }

    private func verdictColor(_ verdict: Verdict) -> Color {
        switch verdict {
        case .right: .green
        case .partial: .orange
        case .wrong: .red
        }
    }
}

// MARK: - Status Pill

private struct StatusPill: View {
    let status: DecisionStatus

    var body: some View {
        Text(status.displayName)
            .font(.system(size: 10, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(pillColor.opacity(0.12)))
            .foregroundStyle(pillColor)
    }

    private var pillColor: Color {
        switch status {
        case .pending: .orange
        case .reviewed30: .blue
        case .reviewed90: .green
        }
    }
}

// MARK: - Filter Button

private struct FilterButton: View {
    let label: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(label)
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(Circle().fill(isSelected ? .white.opacity(0.3) : Color(.systemGray4)))
                }
            }
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Capsule().fill(isSelected ? Color.patchiOrange : Color(.systemGray6)))
            .foregroundStyle(isSelected ? .white : .primary)
        }
    }
}

// MARK: - Preview

#Preview {
    DecisionListView()
        .modelContainer(for: [Decision.self])
}
