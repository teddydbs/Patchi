import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \CheckIn.date, order: .reverse) private var checkIns: [CheckIn]
    @Query(sort: \Decision.createdAt, order: .reverse) private var decisions: [Decision]
    @Query(sort: \AccountabilityEntry.date, order: .reverse) private var accountabilityEntries: [AccountabilityEntry]
    @Query private var users: [User]

    @State private var viewModel = HomeViewModel()
    @State private var showAccountability = false
    @State private var showSettings = false
    @State private var showDecisions = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header avec date et Patchi
                    headerSection

                    // Calendrier semaine
                    weekCalendar

                    // Défi quotidien
                    dailyChallengeCard

                    // Décisions en attente
                    if !pendingDecisions.isEmpty {
                        pendingDecisionsCard
                    }

                    // Dernière entrée
                    if let latest = checkIns.first {
                        latestCheckInCard(latest)
                    }

                    // Bouton accountability du soir
                    accountabilityButton
                }
                .padding(16)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showAccountability) {
                AccountabilityView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showDecisions) {
                DecisionListView()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date().formattedLong)
                    .font(.custom("CrimsonPro-Italic", size: 28, relativeTo: .title))
                    .italic()

                if let user = currentUserName {
                    Text("Salut \(user).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button { showSettings = true } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Week Calendar

    private var weekCalendar: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: -6 + $0, to: today) }

        return HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { date in
                VStack(spacing: 6) {
                    Text(dayLetter(date))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)

                    ZStack {
                        Circle()
                            .fill(date.isToday ? Color.patchiOrange : .clear)
                            .frame(width: 32, height: 32)

                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 14, weight: date.isToday ? .bold : .regular))
                            .foregroundStyle(date.isToday ? .white : .primary)
                    }

                    // Point si entrée ce jour
                    Circle()
                        .fill(hasMoodEntry(on: date) ? .orange : .clear)
                        .frame(width: 4, height: 4)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Daily Challenge

    private var dailyChallengeCard: some View {
        let recentActivities = checkIns.prefix(5).flatMap(\.activities)
        let challenge = viewModel.dailyChallenge(recentActivities: recentActivities)

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Défi du jour", systemImage: "flame.fill")
                    .font(.headline)
                    .foregroundStyle(.orange)
                Spacer()
                Text(viewModel.timeUntilMidnight)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Image(systemName: challenge.icon)
                    .font(.title2)
                    .foregroundStyle(.orange)
                    .frame(width: 40)

                Text(challenge.text)
                    .font(.subheadline)

                Spacer()
            }

            if !viewModel.isDailyChallengeCompleted {
                Button {
                    withAnimation { viewModel.isDailyChallengeCompleted = true }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    Text("C'est fait !")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.patchiOrange)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
            } else {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Bravo !")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
    }

    // MARK: - Pending Decisions

    private var pendingDecisions: [Decision] {
        decisions.filter { $0.status == .pending }
    }

    private var pendingDecisionsCard: some View {
        Button { showDecisions = true } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("\(pendingDecisions.count) décision\(pendingDecisions.count > 1 ? "s" : "") en attente", systemImage: "clock.fill")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                ForEach(pendingDecisions.prefix(3)) { decision in
                    HStack {
                        Text(decision.title)
                            .font(.subheadline)
                            .lineLimit(1)
                        Spacer()
                        Text("J-\(decision.reviewAt30.daysSinceNow)")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .foregroundStyle(.primary)
        }
        .buttonStyle(.plain)
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
    }

    // MARK: - Latest Check-in

    private func latestCheckInCard(_ checkIn: CheckIn) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Dernier check-in")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(checkIn.date.formattedRelative)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            HStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.mood(score: checkIn.moodScore))
                    .frame(width: 4, height: 30)

                VStack(alignment: .leading, spacing: 2) {
                    Text(checkIn.title ?? "Humeur : \(checkIn.moodScore)/5")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    if let reformulation = checkIn.reformulation {
                        Text(reformulation)
                            .font(.caption)
                            .italic()
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
    }

    // MARK: - Accountability Button

    private var accountabilityButton: some View {
        Button {
            showAccountability = true
        } label: {
            HStack {
                Image(systemName: "moon.fill")
                    .foregroundStyle(.indigo)
                Text("Check-in du soir")
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private var currentUserName: String? {
        users.first?.firstName
    }

    private func hasMoodEntry(on date: Date) -> Bool {
        checkIns.contains { $0.date.isSameDay(as: date) }
    }

    private func dayLetter(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date).uppercased()
    }
}
