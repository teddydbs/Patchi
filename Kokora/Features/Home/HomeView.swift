import SwiftUI
import SwiftData

// MARK: - HomeView

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
    @State private var blobsAnimating = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mdBg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        heroSection

                        calendarStrip
                            .padding(.top, 24)

                        checkInCTA
                            .padding(.top, 24)

                        if checkIns.isEmpty && accountabilityEntries.isEmpty {
                            welcomeCard
                                .padding(.top, 24)
                        }

                        challengeSection
                            .padding(.top, 28)

                        let pending = viewModel.pendingDecisions(from: decisions)
                        if !pending.isEmpty {
                            pendingSection(pending)
                                .padding(.top, 28)
                        }

                        if let latest = checkIns.first {
                            lastCheckInSection(latest)
                                .padding(.top, 28)
                        }

                        accountabilitySection
                            .padding(.top, 16)

                        dailyQuoteSection
                            .padding(.top, 16)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 28)
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
            .onAppear {
                withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) {
                    blobsAnimating = true
                }
            }
        }
    }

    // MARK: - Hero Section (Blobs + Greeting)

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top bar : bouton réglages à droite
            HStack {
                Spacer()
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.mdTextGray)
                        .frame(width: 42, height: 42)
                        .background(Color.mdBgSubtle)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Réglages")
            }

            // Blob characters floating
            ZStack {
                // Companion blobs — real Kokora illustrations
                companionBlob(imageName: "emotion_chanceux", size: 44, xOffset: -120, yOffset: -10, delay: 1.0)
                companionBlob(imageName: "emotion_serein", size: 40, xOffset: 110, yOffset: -20, delay: 2.0)
                companionBlob(imageName: "emotion_nostalgique", size: 34, xOffset: -55, yOffset: 40, delay: 0.5)
                companionBlob(imageName: "emotion_surpris", size: 32, xOffset: 70, yOffset: 35, delay: 2.5)

                // Kokora main blob
                Image("emotion_heureux")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 90, height: 90)
                    .offset(y: blobsAnimating ? -6 : 0)
                    .animation(
                        .easeInOut(duration: 3.5).repeatForever(autoreverses: true),
                        value: blobsAnimating
                    )
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)

            // Greeting
            if let name = viewModel.currentUserName(from: users) {
                Text("Bonjour, \(name)")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(Color.mdTextBlack)
                    .tracking(-0.8)
            } else {
                Text("Bonjour")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(Color.mdTextBlack)
                    .tracking(-0.8)
            }

            Text("Comment tu te sens aujourd'hui ?")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(Color.mdTextGray)
        }
        .padding(.top, 12)
    }

    private func companionBlob(imageName: String, size: CGFloat, xOffset: CGFloat, yOffset: CGFloat, delay: Double) -> some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .offset(x: xOffset, y: yOffset)
            .offset(y: blobsAnimating ? -4 : 0)
            .animation(
                .easeInOut(duration: 4).repeatForever(autoreverses: true).delay(delay),
                value: blobsAnimating
            )
    }

    // MARK: - Calendar Strip (Mood Faces)

    private var calendarStrip: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: -6 + $0, to: today) }

        return HStack(spacing: 0) {
            ForEach(weekDays, id: \.self) { date in
                VStack(spacing: 8) {
                    Text(viewModel.dayLetter(date))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.mdTextLight)
                        .textCase(.uppercase)

                    let mood = viewModel.moodScore(on: date, in: checkIns)
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(mood != nil ? Color.moodVivid(mood!) : Color.mdBgSubtle)
                            .frame(width: 42, height: 42)

                        // Kokora illustration based on mood
                        if let mood {
                            Image(moodImageName(score: mood))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                        } else {
                            Image("emotion_seul")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 26, height: 26)
                                .opacity(0.3)
                        }
                    }
                    .overlay(
                        Group {
                            if date.isToday {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(Color.mdTextBlack, lineWidth: 2.5)
                                    .frame(width: 42, height: 42)
                            }
                        }
                    )
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func moodImageName(score: Int) -> String {
        switch score {
        case 5: return "emotion_heureux"
        case 4: return "emotion_serein"
        case 3: return "emotion_nostalgique"
        case 2: return "emotion_triste"
        case 1: return "emotion_seul"
        default: return "emotion_serein"
        }
    }

    // MARK: - Check-in CTA

    private var checkInCTA: some View {
        Button {
            Haptics.light()
            appState.selectedTab = .newEntry
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.mdGreen)

                // Decorative circles
                Circle()
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 100, height: 100)
                    .offset(x: 110, y: -35)

                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 60, height: 60)
                    .offset(x: 50, y: 30)

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Comment tu vas ?")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.white)
                            .tracking(-0.3)

                        Text("Fais ton check-in du jour")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.white.opacity(0.75))
                    }

                    Spacer()

                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        )
                }
                .padding(24)
            }
            .frame(height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(SpringPressStyle())
    }

    // MARK: - Welcome Card

    private var welcomeCard: some View {
        VStack(spacing: 16) {
            EmotionBubble(
                emotion: .heureux,
                text: {
                    if let name = viewModel.currentUserName(from: users) {
                        return "Bienvenue \(name). Ton journal t'attend."
                    }
                    return "Bienvenue. Ton journal t'attend."
                }(),
                size: .medium,
                style: .emotional
            )

            Text("Fais ton premier check-in pour commencer.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.mdTextGray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.mdOrangeBg)
        )
    }

    // MARK: - Challenge Section

    private var challengeSection: some View {
        let recentActivities = checkIns.prefix(5).flatMap(\.activities)
        let challenge = viewModel.dailyChallenge(recentActivities: recentActivities)

        return VStack(alignment: .leading, spacing: 14) {
            // Section header
            HStack {
                Text("Défi du jour")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.mdTextBlack)
                    .tracking(-0.3)

                Spacer()

                Text(viewModel.timeUntilMidnight)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.mdGreen)
            }

            // Challenge card
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.mdOrangeBg)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: challenge.icon)
                                .font(.system(size: 18))
                                .foregroundStyle(Color.mdOrange)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Challenge")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.mdTextBlack)

                        Text("Connexion")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color.mdTextLight)
                    }
                }

                Text(challenge.text)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.mdTextGray)
                    .lineSpacing(4)

                if !viewModel.isDailyChallengeCompleted {
                    Button {
                        Haptics.light()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            viewModel.isDailyChallengeCompleted = true
                        }
                    } label: {
                        Text("C'est fait !")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.mdGreen)
                            )
                    }
                    .buttonStyle(SpringPressStyle())
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.mdGreen)
                        Text("Bravo !")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.mdGreen)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.mdBgSubtle)
            )
        }
    }

    // MARK: - Pending Decisions

    private func pendingSection(_ pendingDecisions: [Decision]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Décisions")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.mdTextBlack)
                    .tracking(-0.3)

                Spacer()

                Button {
                    Haptics.light()
                    showDecisions = true
                } label: {
                    Text("Voir tout")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.mdGreen)
                }
            }

            Button {
                Haptics.light()
                showDecisions = true
            } label: {
                VStack(spacing: 12) {
                    ForEach(pendingDecisions.prefix(3)) { decision in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.accentPurple.opacity(0.2))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Image(systemName: "clock.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color.accentPurple)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(decision.title)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color.mdTextBlack)
                                    .lineLimit(1)

                                Text("Verdict dans J-\(decision.reviewAt30.daysSinceNow)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color.mdTextGray)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.mdTextLight)
                        }
                        .padding(.vertical, 4)

                        if decision.id != pendingDecisions.prefix(3).last?.id {
                            Divider()
                                .foregroundStyle(Color.mdBorder)
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.mdBgSubtle)
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Last Check-in

    private func lastCheckInSection(_ checkIn: CheckIn) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Dernier check-in")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.mdTextBlack)
                    .tracking(-0.3)

                Spacer()

                Text("Voir tout")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.mdGreen)
            }

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Humeur du jour")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.mdTextBlack)

                    Spacer()

                    Text(checkIn.date.formattedRelative)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.mdTextGray)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(Color.white)
                        )
                }

                HStack(spacing: 16) {
                    // Mood Kokora illustration
                    Image(moodImageName(score: checkIn.moodScore))
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 56, height: 56)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(checkIn.title ?? "Humeur : \(checkIn.moodScore)/5")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.mdTextBlack)
                            .tracking(-0.3)

                        if let reformulation = checkIn.reformulation {
                            Text(reformulation)
                                .font(.custom("CrimsonPro-Italic", size: 15))
                                .foregroundStyle(Color.mdTextGray)
                                .lineSpacing(2)
                                .lineLimit(2)
                        }
                    }

                    Spacer()
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.mdGreenBg)
            )
        }
    }

    // MARK: - Accountability

    private var accountabilitySection: some View {
        Button {
            Haptics.light()
            showAccountability = true
        } label: {
            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.accentPurple.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "moon.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(Color.accentPurple)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text("Bilan du soir")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.mdTextBlack)
                    Text("Prends un moment pour toi")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.mdTextGray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.mdTextLight)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.mdBgSubtle)
            )
        }
        .buttonStyle(SpringPressStyle())
    }

    // MARK: - Daily Quote

    private var dailyQuoteSection: some View {
        let seed = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        let quote = allQuotes[seed % allQuotes.count]

        return VStack(spacing: 8) {
            Text("\u{201C}\(quote.text)\u{201D}")
                .font(.custom("CrimsonPro-Italic", size: 17))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.mdTextGray)
                .lineSpacing(3)

            Text("— \(quote.author)")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.mdTextLight)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
    }
}

