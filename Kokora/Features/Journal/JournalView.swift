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
                Color.mdBg.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Custom header
                    HStack {
                        Text("Journal")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundStyle(Color.mdTextBlack)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                    // Toggle mode
                    HStack {
                        FilterChipDS(
                            label: viewModel.showAllEntries ? "Par jour" : "Tout voir",
                            isSelected: false,
                            color: .mdGreen
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.showAllEntries.toggle()
                                if viewModel.showAllEntries {
                                    viewModel.selectedDate = nil
                                } else {
                                    viewModel.selectedDate = Date()
                                }
                            }
                        }
                        .padding(.leading, 20)
                        Spacer()
                    }
                    .padding(.bottom, 6)

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

                    countersRow
                    filterRow

                    if filteredEntries.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 14) {
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
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onChange(of: appState.journalDate) { _, newDate in
                guard let date = newDate else { return }
                viewModel.showAllEntries = false
                viewModel.selectedDate = date
                appState.journalDate = nil
            }
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
        return HStack(spacing: 0) {
            CounterBadge(value: counts.reflections, label: "reflexions")
            Spacer()
            CounterBadge(value: counts.checkIns, label: "check-ins")
            Spacer()
            CounterBadge(value: counts.photos, label: "photos")
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 10)
    }

    // MARK: - Filters

    private var filterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(JournalViewModel.JournalFilter.allCases) { filter in
                    FilterChipDS(
                        label: filter.label,
                        isSelected: viewModel.selectedFilter == filter,
                        color: .mdGreen
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedFilter = filter
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 14) {
            Spacer()
            Image("emotion_confus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
            Text("Rien ici pour l'instant.")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.mdTextGray)
            Text("Fais ton premier check-in !")
                .font(.system(size: 14))
                .foregroundStyle(Color.mdTextLight)
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
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.mdTextBlack)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.mdTextGray)
        }
    }
}
