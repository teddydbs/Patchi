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
                Color.dsBackground.ignoresSafeArea()

                if checkIns.count < 3 {
                    // Écran de déblocage — comme Reflectly
                    unlockScreen
                } else {
                    ScrollView {
                        VStack(spacing: DS.Spacing.xl) {
                            if let countdown = viewModel.countdown(totalCheckIns: checkIns.count) {
                                CountdownCard(message: countdown.message, remaining: countdown.remaining)
                            }

                            weeklyMoodChart
                            monthlyMoodChart
                            correlationsSection
                            heatmapSection
                            decisionStats
                        }
                        .padding(DS.Spacing.lg)
                    }
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Unlock Screen

    private var unlockScreen: some View {
        VStack(spacing: DS.Spacing.xxl) {
            Spacer()

            PatchiView(expression: .curious, size: .hero, animated: false)

            Text("\(max(0, 3 - checkIns.count))")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(Color.patchiOrange)

            Text("check-ins avant de débloquer\ntes premières stats")
                .font(.system(size: DS.Font.body, weight: .medium))
                .foregroundStyle(Color.dsTextSecondary)
                .multilineTextAlignment(.center)

            Text("Patchi apprend encore à te connaître.\nReviens après quelques check-ins !")
                .font(.system(size: DS.Font.caption))
                .foregroundStyle(Color.dsTextSecondary.opacity(0.7))
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(DS.Spacing.lg)
    }

    // MARK: - Weekly Mood Chart

    private var weeklyMoodChart: some View {
        let data = viewModel.weeklyMoods(from: checkIns)
        let hasData = data.contains { $0.averageScore > 0 }

        return StatsCard(title: "Humeur — 7 derniers jours", icon: "chart.line.uptrend.xyaxis") {
            if hasData {
                Chart(data) { entry in
                    LineMark(
                        x: .value("Jour", entry.date, unit: .day),
                        y: .value("Humeur", entry.averageScore)
                    )
                    .foregroundStyle(Color.patchiOrange)
                    .interpolationMethod(.catmullRom)

                    AreaMark(
                        x: .value("Jour", entry.date, unit: .day),
                        y: .value("Humeur", entry.averageScore)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.patchiOrange.opacity(0.3), .clear],
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

        return StatsCard(title: "Humeur — 30 derniers jours", icon: "calendar") {
            if hasData {
                Chart(data) { entry in
                    LineMark(
                        x: .value("Jour", entry.date, unit: .day),
                        y: .value("Humeur", entry.averageScore)
                    )
                    .foregroundStyle(Color.accentPurple)
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

        return StatsCard(title: "Corrélations", icon: "arrow.triangle.merge") {
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                if let phrase = insightPhrase {
                    HStack(spacing: DS.Spacing.sm) {
                        PatchiView(expression: .proud, size: .small)
                        Text(phrase)
                            .font(.patchiBody(15))
                            .italic()
                            .foregroundStyle(Color.dsTextPrimary)
                    }
                    .padding(.bottom, DS.Spacing.xs)
                }

                if correlations.isEmpty {
                    Text("Pas encore assez de données pour les corrélations.")
                        .font(.system(size: DS.Font.caption))
                        .foregroundStyle(Color.dsTextSecondary)
                } else {
                    ForEach(correlations.prefix(5)) { correlation in
                        HStack {
                            Image(systemName: correlation.activity.icon)
                                .font(.caption)
                                .frame(width: 20)
                                .foregroundStyle(Color.dsTextSecondary)
                            Text(correlation.activity.displayName)
                                .font(.system(size: DS.Font.caption))
                                .foregroundStyle(Color.dsTextPrimary)
                            Spacer()
                            MoodDots(score: correlation.averageMood)
                            Text(String(format: "%.1f", correlation.averageMood))
                                .font(.system(size: DS.Font.caption, weight: .semibold))
                                .foregroundStyle(Color.dsTextSecondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Heatmap

    private var heatmapSection: some View {
        StatsCard(title: "Accountability — 90 jours", icon: "square.grid.3x3.fill") {
            let days = viewModel.heatmapDays(from: accountabilityEntries)
            HeatmapWithLegend(days: days, showStats: true)
        }
    }

    // MARK: - Decision Stats

    private var decisionStats: some View {
        let counts = viewModel.decisionCounts(from: decisions)

        return StatsCard(title: "Décisions", icon: "arrow.triangle.branch") {
            HStack(spacing: DS.Spacing.xl) {
                StatNumber(value: counts.total, label: "Total", color: .dsTextPrimary)
                StatNumber(value: counts.pending, label: "En attente", color: .accentAmber)
                StatNumber(value: counts.reviewed, label: "Reviewées", color: .dsSuccess)
            }
        }
    }

    private var emptyChartPlaceholder: some View {
        VStack(spacing: DS.Spacing.sm) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title2)
                .foregroundStyle(Color.dsTextSecondary.opacity(0.5))
            Text("Pas encore assez de données")
                .font(.system(size: DS.Font.caption))
                .foregroundStyle(Color.dsTextSecondary)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Stats Card (Clay)

private struct StatsCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        ClayCard {
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                Label(title, systemImage: icon)
                    .font(.system(size: DS.Font.body, weight: .semibold))
                    .foregroundStyle(Color.dsTextPrimary)

                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct CountdownCard: View {
    let message: String
    let remaining: Int

    var body: some View {
        ClayCard(tint: .patchiOrange) {
            HStack(spacing: DS.Spacing.md) {
                PatchiView(expression: .curious, size: .small)
                Text(message)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.dsTextPrimary)
                Spacer()
            }
        }
    }
}

private struct StatNumber: View {
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.dsTextSecondary)
        }
    }
}

private struct MoodDots: View {
    let score: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { i in
                Circle()
                    .fill(Double(i) <= score ? Color.mood(score: Int(score.rounded())) : Color.dsBorder)
                    .frame(width: 6, height: 6)
            }
        }
    }
}
