import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CheckIn.date, order: .reverse) private var checkIns: [CheckIn]
    @Query(sort: \AccountabilityEntry.date, order: .reverse) private var accountabilityEntries: [AccountabilityEntry]
    @Query(sort: \Decision.createdAt, order: .reverse) private var decisions: [Decision]
    @Query(sort: \FutureLetter.writtenAt, order: .reverse) private var letters: [FutureLetter]

    @State private var viewModel = JournalViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.dsBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Toggle mode
                    HStack {
                        FilterChipDS(
                            label: viewModel.showAllEntries ? "Par jour" : "Tout voir",
                            isSelected: false
                        ) {
                            withAnimation(DS.Animation.micro) {
                                viewModel.showAllEntries.toggle()
                                if viewModel.showAllEntries {
                                    viewModel.selectedDate = nil
                                } else {
                                    viewModel.selectedDate = Date()
                                }
                            }
                        }
                        .padding(.leading, DS.Spacing.lg)
                        Spacer()
                    }
                    .padding(.top, DS.Spacing.xs)

                    if !viewModel.showAllEntries {
                        CalendarStripView(
                            selectedDate: Binding(
                                get: { viewModel.selectedDate ?? Date() },
                                set: { viewModel.selectedDate = $0 }
                            ),
                            markedDates: viewModel.markedDates(
                                checkIns: checkIns,
                                accountabilityEntries: accountabilityEntries,
                                decisions: decisions,
                                letters: letters
                            )
                        )
                        .padding(.vertical, DS.Spacing.sm)
                    }

                    countersRow
                    filterRow

                    if filteredEntries.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: DS.Spacing.md) {
                                ForEach(filteredEntries, id: \.id) { entry in
                                    entryCard(for: entry)
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                deleteEntry(entry)
                                            } label: {
                                                Label("Supprimer", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .padding(.horizontal, DS.Spacing.lg)
                            .padding(.vertical, DS.Spacing.md)
                        }
                    }
                }
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Counters

    private var countersRow: some View {
        let counts = viewModel.counts(
            checkIns: checkIns,
            accountabilityEntries: accountabilityEntries,
            decisions: decisions,
            letters: letters
        )
        return HStack(spacing: DS.Spacing.xl) {
            CounterBadge(value: counts.reflections, label: "reflexions")
            CounterBadge(value: counts.checkIns, label: "check-ins")
            CounterBadge(value: counts.photos, label: "photos")
        }
        .padding(.horizontal, DS.Spacing.lg)
        .padding(.bottom, DS.Spacing.sm)
    }

    // MARK: - Filters

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DS.Spacing.sm) {
                ForEach(JournalViewModel.JournalFilter.allCases) { filter in
                    FilterChipDS(
                        label: filter.label,
                        isSelected: viewModel.selectedFilter == filter
                    ) {
                        withAnimation(DS.Animation.micro) {
                            viewModel.selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.vertical, 6)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DS.Spacing.md) {
            Spacer()
            PatchiView(expression: .curious, size: .large)
            Text("Rien ici pour l'instant.")
                .font(.system(size: DS.Font.body, weight: .medium))
                .foregroundStyle(Color.dsTextSecondary)
            Text("Fais ton premier check-in !")
                .font(.system(size: DS.Font.caption))
                .foregroundStyle(Color.dsTextSecondary.opacity(0.7))
            Spacer()
        }
    }

    // MARK: - Unified Entry Model

    private struct UnifiedEntry: Identifiable {
        let id: String
        let date: Date
        let type: JournalEntryType
        let checkIn: CheckIn?
        let accountability: AccountabilityEntry?
        let decision: Decision?
        let letter: FutureLetter?
    }

    private var filteredEntries: [UnifiedEntry] {
        var entries: [UnifiedEntry] = []

        if viewModel.selectedFilter == .all || viewModel.selectedFilter == .checkIns {
            for c in checkIns where matchesDateFilter(c.date) {
                entries.append(UnifiedEntry(id: "ci-\(c.id)", date: c.date, type: .checkIn, checkIn: c, accountability: nil, decision: nil, letter: nil))
            }
        }

        if viewModel.selectedFilter == .all || viewModel.selectedFilter == .accountability {
            for a in accountabilityEntries where matchesDateFilter(a.date) {
                entries.append(UnifiedEntry(id: "ac-\(a.id)", date: a.date, type: .accountability, checkIn: nil, accountability: a, decision: nil, letter: nil))
            }
        }

        if viewModel.selectedFilter == .all || viewModel.selectedFilter == .decisions {
            for d in decisions where matchesDateFilter(d.createdAt) {
                entries.append(UnifiedEntry(id: "de-\(d.id)", date: d.createdAt, type: .decision, checkIn: nil, accountability: nil, decision: d, letter: nil))
            }
        }

        if viewModel.selectedFilter == .all || viewModel.selectedFilter == .letters {
            for l in letters where matchesDateFilter(l.writtenAt) {
                entries.append(UnifiedEntry(id: "le-\(l.id)", date: l.writtenAt, type: .letter, checkIn: nil, accountability: nil, decision: nil, letter: l))
            }
        }

        return entries.sorted { $0.date > $1.date }
    }

    private func deleteEntry(_ entry: UnifiedEntry) {
        if let checkIn = entry.checkIn {
            modelContext.delete(checkIn)
        } else if let acc = entry.accountability {
            modelContext.delete(acc)
        } else if let dec = entry.decision {
            NotificationService.shared.removeDecisionReminders(decisionId: dec.id)
            modelContext.delete(dec)
        } else if let letter = entry.letter {
            NotificationService.shared.removeLetterDelivery(letterId: letter.id)
            modelContext.delete(letter)
        }
    }

    private func matchesDateFilter(_ date: Date) -> Bool {
        guard let selectedDate = viewModel.selectedDate else { return true }
        return date.isSameDay(as: selectedDate)
    }

    @ViewBuilder
    private func entryCard(for entry: UnifiedEntry) -> some View {
        switch entry.type {
        case .checkIn:
            if let checkIn = entry.checkIn {
                CheckInCardView(checkIn: checkIn)
            }
        case .accountability:
            if let acc = entry.accountability {
                AccountabilityCardView(entry: acc)
            }
        case .decision:
            if let dec = entry.decision {
                DecisionCardView(decision: dec)
            }
        case .letter:
            if let letter = entry.letter {
                LetterCardView(letter: letter)
            }
        }
    }
}

// MARK: - Counter Badge

private struct CounterBadge: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color.dsTextPrimary)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.dsTextSecondary)
        }
    }
}
