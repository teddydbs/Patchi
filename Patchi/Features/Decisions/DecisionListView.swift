import SwiftUI
import SwiftData

struct DecisionListView: View {
    @Query(sort: \Decision.createdAt, order: .reverse) private var decisions: [Decision]
    @State private var viewModel = DecisionListViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.dsBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    filterBar

                    let filtered = viewModel.filteredDecisions(from: decisions)
                    if filtered.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: DS.Spacing.md) {
                                ForEach(filtered) { decision in
                                    DecisionRow(decision: decision) {
                                        viewModel.handleVerdictTap(for: decision)
                                    }
                                }
                            }
                            .padding(.horizontal, DS.Spacing.lg)
                            .padding(.top, DS.Spacing.sm)
                        }
                    }
                }
            }
            .navigationTitle("Décisions")
            .sheet(isPresented: $viewModel.showVerdict) {
                if let decision = viewModel.selectedDecision {
                    VerdictView(decision: decision, verdictType: viewModel.verdictType)
                }
            }
        }
    }

    // MARK: - Filters

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
                FilterChipDS(
                    label: "Toutes (\(decisions.count))",
                    isSelected: viewModel.selectedFilter == nil
                ) {
                    viewModel.selectedFilter = nil
                }
                ForEach(DecisionStatus.allCases, id: \.rawValue) { status in
                    let count = decisions.filter { $0.status == status }.count
                    FilterChipDS(
                        label: "\(status.displayName) (\(count))",
                        isSelected: viewModel.selectedFilter == status,
                        color: statusColor(status)
                    ) {
                        viewModel.selectedFilter = status
                    }
                }
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.vertical, DS.Spacing.sm)
        }
    }

    private var emptyState: some View {
        VStack(spacing: DS.Spacing.md) {
            Spacer()
            PatchiView(expression: .curious, size: .large)
            Text("Aucune décision enregistrée.")
                .font(.system(size: DS.Font.body, weight: .medium))
                .foregroundStyle(Color.dsTextSecondary)
            Text("Appuie sur + pour en créer une.")
                .font(.system(size: DS.Font.caption))
                .foregroundStyle(Color.dsTextSecondary.opacity(0.7))
            Spacer()
        }
    }

    private func statusColor(_ status: DecisionStatus) -> Color {
        switch status {
        case .pending: .accentAmber
        case .reviewed30: .accentPurple
        case .reviewed90: .dsSuccess
        }
    }
}

// MARK: - Decision Row

private struct DecisionRow: View {
    let decision: Decision
    let onVerdictTap: () -> Void

    var body: some View {
        ClayCard {
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                HStack {
                    Text(decision.title)
                        .font(.system(size: DS.Font.body, weight: .semibold))
                        .foregroundStyle(Color.dsTextPrimary)
                    Spacer()
                    importanceStars
                }

                Text(decision.decision)
                    .font(.system(size: 15))
                    .foregroundStyle(Color.dsTextSecondary)
                    .lineLimit(2)

                HStack {
                    StatusPill(status: decision.status)
                    Spacer()

                    if decision.status == .pending {
                        let daysToVerdict = decision.reviewAt30.daysSinceNow
                        if daysToVerdict <= 0 {
                            Button("Donner le verdict") {
                                Haptics.medium()
                                onVerdictTap()
                            }
                            .font(.system(size: DS.Font.caption, weight: .bold))
                            .foregroundStyle(Color.patchiOrange)
                        } else {
                            Text("J-\(daysToVerdict)")
                                .font(.system(size: DS.Font.caption, weight: .bold))
                                .foregroundStyle(Color.accentAmber)
                        }
                    } else if decision.status == .reviewed30 {
                        if let verdict = decision.verdict30 {
                            Label(verdict.displayName, systemImage: verdict.icon)
                                .font(.system(size: DS.Font.caption, weight: .medium))
                                .foregroundStyle(verdictColor(verdict))
                        }
                        let daysTo90 = decision.reviewAt90.daysSinceNow
                        if daysTo90 <= 0 {
                            Button("Verdict J+90") {
                                Haptics.medium()
                                onVerdictTap()
                            }
                            .font(.system(size: DS.Font.caption, weight: .bold))
                            .foregroundStyle(Color.accentPurple)
                        }
                    } else if decision.status == .reviewed90 {
                        if let verdict = decision.verdict90 {
                            Label(verdict.displayName, systemImage: verdict.icon)
                                .font(.system(size: DS.Font.caption, weight: .medium))
                                .foregroundStyle(verdictColor(verdict))
                        }
                    }
                }

                Text(decision.createdAt.formattedShort)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.dsTextSecondary.opacity(0.6))
            }
        }
    }

    private var importanceStars: some View {
        HStack(spacing: 2) {
            ForEach(0..<decision.importance, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.accentAmber)
            }
        }
    }

    private func verdictColor(_ verdict: Verdict) -> Color {
        switch verdict {
        case .right: .dsSuccess
        case .partial: .accentAmber
        case .wrong: .dsDestructive
        }
    }
}

// MARK: - Status Pill

private struct StatusPill: View {
    let status: DecisionStatus

    var body: some View {
        Text(status.displayName)
            .font(.system(size: 10, weight: .semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule(style: .continuous).fill(pillColor.opacity(0.12)))
            .foregroundStyle(pillColor)
    }

    private var pillColor: Color {
        switch status {
        case .pending: .accentAmber
        case .reviewed30: .accentPurple
        case .reviewed90: .dsSuccess
        }
    }
}

#Preview {
    DecisionListView()
        .modelContainer(for: [Decision.self])
}
