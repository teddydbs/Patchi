import SwiftUI
import SwiftData

struct DecisionListView: View {
    @Query(sort: \Decision.createdAt, order: .reverse) private var decisions: [Decision]
    @State private var viewModel = DecisionListViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mdBg.ignoresSafeArea()

                VStack(spacing: 0) {
                    filterBar

                    let filtered = viewModel.filteredDecisions(from: decisions)
                    if filtered.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filtered) { decision in
                                    DecisionRow(decision: decision) {
                                        viewModel.handleVerdictTap(for: decision)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
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
            HStack(spacing: 8) {
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
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            PatchiView(expression: .curious, size: .large)
            Text("Aucune décision enregistrée.")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Color.mdTextGray)
            Text("Appuie sur + pour en créer une.")
                .font(.system(size: 13))
                .foregroundStyle(Color.mdTextLight)
            Spacer()
        }
    }

    private func statusColor(_ status: DecisionStatus) -> Color {
        switch status {
        case .pending: .mdOrange
        case .reviewed30: .mdPurple
        case .reviewed90: .mdGreen
        }
    }
}

// MARK: - Decision Row

private struct DecisionRow: View {
    let decision: Decision
    let onVerdictTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(decision.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.mdTextBlack)
                Spacer()
                importanceStars
            }

            Text(decision.decision)
                .font(.system(size: 15))
                .foregroundStyle(Color.mdTextGray)
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
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.mdOrange)
                    } else {
                        Text("J-\(daysToVerdict)")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color.mdOrange)
                    }
                } else if decision.status == .reviewed30 {
                    if let verdict = decision.verdict30 {
                        Label(verdict.displayName, systemImage: verdict.icon)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(verdictColor(verdict))
                    }
                    let daysTo90 = decision.reviewAt90.daysSinceNow
                    if daysTo90 <= 0 {
                        Button("Verdict J+90") {
                            Haptics.medium()
                            onVerdictTap()
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Color.mdPurple)
                    }
                } else if decision.status == .reviewed90 {
                    if let verdict = decision.verdict90 {
                        Label(verdict.displayName, systemImage: verdict.icon)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(verdictColor(verdict))
                    }
                }
            }

            Text(decision.createdAt.formattedShort)
                .font(.system(size: 11))
                .foregroundStyle(Color.mdTextLight)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.mdBgSubtle)
        )
    }

    private var importanceStars: some View {
        HStack(spacing: 2) {
            ForEach(0..<decision.importance, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.mdYellow)
            }
        }
    }

    private func verdictColor(_ verdict: Verdict) -> Color {
        switch verdict {
        case .right: .mdGreen
        case .partial: .mdYellow
        case .wrong: Color(red: 0.90, green: 0.30, blue: 0.30)
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
            .background(Capsule(style: .continuous).fill(pillColor.opacity(0.15)))
            .foregroundStyle(pillColor)
    }

    private var pillColor: Color {
        switch status {
        case .pending: .mdOrange
        case .reviewed30: .mdPurple
        case .reviewed90: .mdGreen
        }
    }
}

#Preview {
    DecisionListView()
        .modelContainer(for: [Decision.self])
}
