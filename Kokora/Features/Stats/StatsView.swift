import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \CheckIn.date) private var checkIns: [CheckIn]
    @Query(sort: \AccountabilityEntry.date) private var accountabilityEntries: [AccountabilityEntry]
    @Query(sort: \Decision.createdAt) private var decisions: [Decision]

    @State private var viewModel = StatsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.mdBg.ignoresSafeArea()

                if checkIns.count < 3 {
                    unlockScreen
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Custom header
                            HStack {
                                Text("Stats")
                                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                                    .foregroundStyle(Color.mdTextBlack)
                                Spacer()
                            }
                            .padding(.top, 8)

                            if let countdown = viewModel.countdown(totalCheckIns: checkIns.count) {
                                CountdownCard(message: countdown.message, remaining: countdown.remaining)
                            }

                            weeklyMoodChart
                            monthlyMoodChart
                            correlationsSection
                            heatmapSection
                            decisionStats
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Unlock Screen

    private var unlockScreen: some View {
        VStack(spacing: 32) {
            Spacer()

            Image("emotion_heureux")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)

            Text("\(max(0, 3 - checkIns.count))")
                .font(.system(size: 72, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.mdOrange)

            Text("check-ins avant de débloquer\ntes premières stats")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.mdTextGray)
                .multilineTextAlignment(.center)

            Text("Encore un peu de patience.\nReviens après quelques check-ins !")
                .font(.system(size: 14))
                .foregroundStyle(Color.mdTextLight)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Weekly Mood Chart

    private var weeklyMoodChart: some View {
        let data = viewModel.weeklyMoods(from: checkIns)
        let hasData = data.contains { $0.averageScore > 0 }

        return StatsCard(title: "Humeur — 7 derniers jours", icon: "chart.line.uptrend.xyaxis", bgColor: .mdGreenBg) {
            if hasData {
                Chart(data) { entry in
                    LineMark(
                        x: .value("Jour", entry.date, unit: .day),
                        y: .value("Humeur", entry.averageScore)
                    )
                    .foregroundStyle(Color.mdGreen)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Jour", entry.date, unit: .day),
                        y: .value("Humeur", entry.averageScore)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.mdGreen.opacity(0.3), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.catmullRom)
                }
                .chartYScale(domain: 0...5)
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) { _ in
                        AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                    }
                }
                .frame(height: 180)
            } else {
                emptyChartPlaceholder
            }
        }
    }

    // MARK: - Monthly Mood Chart

    private var monthlyMoodChart: some View {
        let data = viewModel.monthlyMoods(from: checkIns)
        let hasData = data.contains { $0.averageScore > 0 }

        return StatsCard(title: "Humeur — 30 derniers jours", icon: "calendar", bgColor: .mdPurpleBg) {
            if hasData {
                Chart(data) { entry in
                    LineMark(
                        x: .value("Jour", entry.date, unit: .day),
                        y: .value("Humeur", entry.averageScore)
                    )
                    .foregroundStyle(Color.mdPurple)
                    .interpolationMethod(.catmullRom)
                }
                .chartYScale(domain: 0...5)
                .frame(height: 150)
            } else {
                emptyChartPlaceholder
            }
        }
    }

    // MARK: - Correlations

    private var correlationsSection: some View {
        let correlations = viewModel.correlations(from: checkIns)
        let insightPhrase = viewModel.insightPhrase(from: checkIns)

        return StatsCard(title: "Correlations", icon: "arrow.triangle.merge", bgColor: .mdYellowBg) {
            VStack(alignment: .leading, spacing: 12) {
                if let phrase = insightPhrase {
                    HStack(spacing: 8) {
                        Image("emotion_fiere")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                        Text(phrase)
                            .font(.system(size: 15, weight: .medium))
                            .italic()
                            .foregroundStyle(Color.mdTextBlack)
                    }
                    .padding(.bottom, 4)
                }

                if correlations.isEmpty {
                    Text("Pas encore assez de donnees pour les correlations.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color.mdTextGray)
                } else {
                    ForEach(correlations.prefix(5)) { correlation in
                        HStack {
                            Image(systemName: correlation.activity.icon)
                                .font(.caption)
                                .frame(width: 20)
                                .foregroundStyle(Color.mdTextGray)
                            Text(correlation.activity.displayName)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.mdTextBlack)
                            Spacer()
                            MoodDots(score: correlation.averageMood)
                            Text(String(format: "%.1f", correlation.averageMood))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.mdTextGray)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Heatmap

    private var heatmapSection: some View {
        StatsCard(title: "Accountability — 90 jours", icon: "square.grid.3x3.fill", bgColor: .mdBgSubtle) {
            let days = viewModel.heatmapDays(from: accountabilityEntries)
            HeatmapWithLegend(days: days, showStats: true)
        }
    }

    // MARK: - Decision Stats

    private var decisionStats: some View {
        let counts = viewModel.decisionCounts(from: decisions)

        return StatsCard(title: "Decisions", icon: "arrow.triangle.branch", bgColor: .mdBgSubtle) {
            HStack(spacing: 0) {
                StatNumber(value: counts.total, label: "Total", bgColor: .mdPurpleBg, textColor: .mdPurple)
                Spacer()
                StatNumber(value: counts.pending, label: "En attente", bgColor: .mdYellowBg, textColor: .mdYellow)
                Spacer()
                StatNumber(value: counts.reviewed, label: "Reviewees", bgColor: .mdGreenBg, textColor: .mdGreen)
            }
        }
    }

    private var emptyChartPlaceholder: some View {
        VStack(spacing: 10) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title2)
                .foregroundStyle(Color.mdTextLight)
            Text("Pas encore assez de donnees")
                .font(.system(size: 13))
                .foregroundStyle(Color.mdTextGray)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Stats Card (Motion Design)

private struct StatsCard<Content: View>: View {
    let title: String
    let icon: String
    var bgColor: Color = .mdBgSubtle
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.mdTextBlack)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(bgColor)
        )
    }
}

// MARK: - Countdown Card

private struct CountdownCard: View {
    let message: String
    let remaining: Int

    var body: some View {
        HStack(spacing: 14) {
            Image("emotion_confus")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)

            Text(message)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.mdTextBlack)
            Spacer()
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.mdOrangeBg)
        )
    }
}

// MARK: - Stat Number

private struct StatNumber: View {
    let value: Int
    let label: String
    var bgColor: Color = .mdBgSubtle
    var textColor: Color = .mdTextBlack

    var body: some View {
        VStack(spacing: 6) {
            Text("\(value)")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundStyle(textColor)
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.mdTextGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(bgColor)
        )
    }
}

// MARK: - Mood Dots

private struct MoodDots: View {
    let score: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { i in
                Circle()
                    .fill(Double(i) <= score ? Color.moodVivid(Int(score.rounded())) : Color.mdBorder)
                    .frame(width: 6, height: 6)
            }
        }
    }
}
