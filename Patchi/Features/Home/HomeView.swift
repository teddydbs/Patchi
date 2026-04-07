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
            ZStack {
                // Fond teinté + blobs
                Color.dsBackground.ignoresSafeArea()
                BlobBackground(
                    colors: blobColors,
                    opacity: 0.12
                )

                ScrollView(showsIndicators: false) {
                    VStack(spacing: DS.Spacing.xl) {
                        headerSection
                            .padding(.top, DS.Spacing.sm)

                        if checkIns.isEmpty && accountabilityEntries.isEmpty {
                            welcomeCard
                        }

                        weekCalendar

                        dailyChallengeCard

                        let pending = viewModel.pendingDecisions(from: decisions)
                        if !pending.isEmpty {
                            pendingDecisionsCard(pending)
                        }

                        if let latest = checkIns.first {
                            latestCheckInCard(latest)
                        }

                        accountabilityButton

                        dailyQuoteCard

                        Spacer(minLength: DS.Spacing.xxl)
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showAccountability) {
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

    // MARK: - Blob Colors

    private var blobColors: [Color] {
        if let mood = checkIns.first?.moodScore {
            return [Color.mood(score: mood), .patchiOrange, Color.mood(score: mood).opacity(0.7)]
        }
        return [.patchiOrange, .accentPurple, .accentAmber]
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(Date().formattedLong)
                    .font(.patchiTitle(DS.Font.cardTitle))
                    .foregroundStyle(Color.dsTextPrimary)

                if let user = viewModel.currentUserName(from: users) {
                    Text("Salut \(user).")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.dsTextSecondary)
                }
            }

            Spacer()

            // Patchi mini + settings
            HStack(spacing: DS.Spacing.md) {
                PatchiView(
                    expression: viewModel.patchiExpression(latestMood: checkIns.first?.moodScore),
                    size: .small,
                    showShadow: false
                )

                Button {
                    Haptics.light()
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundStyle(Color.dsTextSecondary)
                        .frame(width: 44, height: 44)
                }
            }
        }
    }

    // MARK: - Welcome Card

    private var welcomeCard: some View {
        ClayCard(tint: .patchiOrange) {
            VStack(spacing: DS.Spacing.md) {
                PatchiWithBubble(
                    expression: .happy,
                    text: {
                        if let name = viewModel.currentUserName(from: users) {
                            return "Bienvenue \(name). Ton journal t'attend."
                        }
                        return "Bienvenue. Ton journal t'attend."
                    }(),
                    patchiSize: .medium,
                    bubbleStyle: .emotional
                )

                Text("Fais ton premier check-in pour commencer.")
                    .font(.system(size: DS.Font.caption, weight: .medium))
                    .foregroundStyle(Color.dsTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Week Calendar

    private var weekCalendar: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: -6 + $0, to: today) }

        return ClayCard {
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { date in
                    VStack(spacing: 6) {
                        Text(viewModel.dayLetter(date))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.dsTextSecondary)

                        ZStack {
                            if date.isToday {
                                Circle()
                                    .fill(Color.patchiOrange)
                                    .frame(width: 36, height: 36)
                            } else if let mood = viewModel.moodScore(on: date, in: checkIns) {
                                Circle()
                                    .fill(Color.mood(score: mood).opacity(0.2))
                                    .frame(width: 36, height: 36)
                            }

                            Text("\(calendar.component(.day, from: date))")
                                .font(.system(size: 15, weight: date.isToday ? .bold : .regular))
                                .foregroundStyle(date.isToday ? .white : .dsTextPrimary)
                        }
                        .frame(width: 36, height: 36)

                        // Dot mood
                        Circle()
                            .fill(viewModel.dotColor(for: date, in: checkIns))
                            .frame(width: 5, height: 5)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: - Daily Challenge

    private var dailyChallengeCard: some View {
        let recentActivities = checkIns.prefix(5).flatMap(\.activities)
        let challenge = viewModel.dailyChallenge(recentActivities: recentActivities)

        return ClayCard(tint: .patchiOrange) {
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                HStack {
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundStyle(Color.patchiOrange)

                    Text("Défi du jour")
                        .font(.patchiTitle(DS.Font.cardTitle))
                        .foregroundStyle(Color.dsTextPrimary)

                    Spacer()

                    Text(viewModel.timeUntilMidnight)
                        .font(.system(size: DS.Font.caption, weight: .semibold))
                        .foregroundStyle(Color.dsTextSecondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.dsCard))
                }

                HStack(spacing: DS.Spacing.md) {
                    Image(systemName: challenge.icon)
                        .font(.title)
                        .foregroundStyle(Color.patchiOrange)
                        .frame(width: 48, height: 48)
                        .background(
                            Circle()
                                .fill(Color.patchiOrange.opacity(0.12))
                        )

                    Text(challenge.text)
                        .font(.system(size: DS.Font.body, weight: .regular))
                        .foregroundStyle(Color.dsTextPrimary)

                    Spacer()
                }

                if !viewModel.isDailyChallengeCompleted {
                    PillButton(title: "C'est fait !", icon: "checkmark") {
                        withAnimation(DS.Animation.micro) {
                            viewModel.isDailyChallengeCompleted = true
                        }
                    }
                } else {
                    HStack(spacing: DS.Spacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.dsSuccess)
                        Text("Bravo !")
                            .font(.system(size: DS.Font.body, weight: .semibold))
                            .foregroundStyle(Color.dsSuccess)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: DS.buttonHeight)
                    .transition(.clay)
                }
            }
        }
    }

    // MARK: - Pending Decisions

    private func pendingDecisionsCard(_ pendingDecisions: [Decision]) -> some View {
        TappableClayCard(tint: .accentPurple) {
            Haptics.light()
            showDecisions = true
        } content: {
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(Color.accentPurple)
                    Text("\(pendingDecisions.count) décision\(pendingDecisions.count > 1 ? "s" : "") en attente")
                        .font(.system(size: DS.Font.body, weight: .semibold))
                        .foregroundStyle(Color.dsTextPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.dsTextSecondary)
                }

                ForEach(pendingDecisions.prefix(3)) { decision in
                    HStack {
                        Circle()
                            .fill(Color.accentPurple.opacity(0.2))
                            .frame(width: 8, height: 8)
                        Text(decision.title)
                            .font(.system(size: 15))
                            .foregroundStyle(Color.dsTextPrimary)
                            .lineLimit(1)
                        Spacer()
                        Text("J-\(decision.reviewAt30.daysSinceNow)")
                            .font(.system(size: DS.Font.caption, weight: .bold))
                            .foregroundStyle(Color.accentAmber)
                    }
                }
            }
        }
    }

    // MARK: - Latest Check-in

    private func latestCheckInCard(_ checkIn: CheckIn) -> some View {
        ClayCard(tint: Color.mood(score: checkIn.moodScore)) {
            VStack(alignment: .leading, spacing: DS.Spacing.sm) {
                HStack {
                    Text("Dernier check-in")
                        .font(.system(size: DS.Font.caption, weight: .semibold))
                        .foregroundStyle(Color.dsTextSecondary)
                    Spacer()
                    Text(checkIn.date.formattedRelative)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.dsTextSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.dsCard))
                }

                HStack(spacing: DS.Spacing.md) {
                    // Mood indicator circle
                    ZStack {
                        Circle()
                            .fill(Color.mood(score: checkIn.moodScore))
                            .frame(width: 48, height: 48)

                        Text("\(checkIn.moodScore)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.moodText(score: checkIn.moodScore))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(checkIn.title ?? "Humeur : \(checkIn.moodScore)/5")
                            .font(.system(size: DS.Font.body, weight: .semibold))
                            .foregroundStyle(Color.dsTextPrimary)

                        if let reformulation = checkIn.reformulation {
                            Text(reformulation)
                                .font(.patchiBody(14))
                                .italic()
                                .foregroundStyle(Color.dsTextSecondary)
                                .lineLimit(2)
                        }
                    }

                    Spacer()
                }
            }
        }
    }

    // MARK: - Accountability Button

    private var accountabilityButton: some View {
        TappableClayCard {
            showAccountability = true
        } content: {
            HStack(spacing: DS.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.accentPurple.opacity(0.12))
                        .frame(width: 44, height: 44)

                    Image(systemName: "moon.fill")
                        .font(.title3)
                        .foregroundStyle(Color.accentPurple)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Check-in du soir")
                        .font(.system(size: DS.Font.body, weight: .semibold))
                        .foregroundStyle(Color.dsTextPrimary)
                    Text("Prends un moment pour toi")
                        .font(.system(size: DS.Font.caption))
                        .foregroundStyle(Color.dsTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.dsTextSecondary)
            }
        }
    }

    // MARK: - Daily Quote

    private var dailyQuoteCard: some View {
        let seed = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        let quote = allQuotes[seed % allQuotes.count]

        return ZStack {
            RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            quote.category.color.opacity(0.8),
                            quote.category.color.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: DS.Spacing.md) {
                Text(quote.text)
                    .font(.patchiQuote(20))
                    .italic()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)

                Text("— \(quote.author)")
                    .font(.system(size: DS.Font.caption, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(DS.Spacing.xl)
        }
        .frame(minHeight: 140)
        .clayShadow()
    }

    // MARK: - Helpers

}
