import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \CheckIn.date, order: .reverse) private var checkIns: [CheckIn]
    @Query(sort: \AccountabilityEntry.date, order: .reverse) private var accountabilityEntries: [AccountabilityEntry]
    @Query(sort: \Decision.createdAt, order: .reverse) private var decisions: [Decision]
    @Query(sort: \FutureLetter.writtenAt, order: .reverse) private var letters: [FutureLetter]

    @State private var viewModel = JournalViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Toggle mode + calendrier
                HStack {
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            viewModel.showAllEntries.toggle()
                            if viewModel.showAllEntries {
                                viewModel.selectedDate = nil
                            } else {
                                viewModel.selectedDate = Date()
                            }
                        }
                    } label: {
                        Text(viewModel.showAllEntries ? "Par jour" : "Tout voir")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color(.systemGray6)))
                    }
                    .padding(.leading, 16)
                    Spacer()
                }
                .padding(.top, 4)

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
                    .padding(.vertical, 8)
                }

                // Compteurs
                countersRow

                // Filtres
                filterRow

                Divider()

                // Liste des entrées
                if filteredEntries.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(filteredEntries, id: \.id) { entry in
                                entryCard(for: entry)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
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
        return HStack(spacing: 24) {
            CounterBadge(value: counts.reflections, label: "réflexions")
            CounterBadge(value: counts.checkIns, label: "check-ins")
            CounterBadge(value: counts.photos, label: "photos")
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }

    // MARK: - Filters

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(JournalViewModel.JournalFilter.allCases) { filter in
                    Button {
                        withAnimation(.easeOut(duration: 0.2)) {
                            viewModel.selectedFilter = filter
                        }
                    } label: {
                        Text(filter.label)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background {
                                Capsule()
                                    .fill(viewModel.selectedFilter == filter
                                        ? Color.patchiOrange
                                        : Color(.systemGray6))
                            }
                            .foregroundStyle(viewModel.selectedFilter == filter ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            PatchiView(expression: .curious, size: .large)
            Text("Rien ici pour l'instant.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Fais ton premier check-in !")
                .font(.caption)
                .foregroundStyle(.tertiary)
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

        // Check-ins
        if viewModel.selectedFilter == .all || viewModel.selectedFilter == .checkIns {
            for c in checkIns where matchesDateFilter(c.date) {
                entries.append(UnifiedEntry(id: "ci-\(c.id)", date: c.date, type: .checkIn, checkIn: c, accountability: nil, decision: nil, letter: nil))
            }
        }

        // Accountability
        if viewModel.selectedFilter == .all || viewModel.selectedFilter == .accountability {
            for a in accountabilityEntries where matchesDateFilter(a.date) {
                entries.append(UnifiedEntry(id: "ac-\(a.id)", date: a.date, type: .accountability, checkIn: nil, accountability: a, decision: nil, letter: nil))
            }
        }

        // Decisions
        if viewModel.selectedFilter == .all || viewModel.selectedFilter == .decisions {
            for d in decisions where matchesDateFilter(d.createdAt) {
                entries.append(UnifiedEntry(id: "de-\(d.id)", date: d.createdAt, type: .decision, checkIn: nil, accountability: nil, decision: d, letter: nil))
            }
        }

        // Letters
        if viewModel.selectedFilter == .all || viewModel.selectedFilter == .letters {
            for l in letters where matchesDateFilter(l.writtenAt) {
                entries.append(UnifiedEntry(id: "le-\(l.id)", date: l.writtenAt, type: .letter, checkIn: nil, accountability: nil, decision: nil, letter: l))
            }
        }

        return entries.sorted { $0.date > $1.date }
    }

    private func matchesDateFilter(_ date: Date) -> Bool {
        guard let selectedDate = viewModel.selectedDate else {
            return true // Pas de filtre date = tout montrer
        }
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
                .font(.headline)
                .fontWeight(.bold)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
}
