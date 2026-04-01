import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Environment(AppState.self) private var appState
    @Query(sort: \CheckIn.date) private var checkIns: [CheckIn]
    @Query(sort: \AccountabilityEntry.date) private var accountabilityEntries: [AccountabilityEntry]
    @Query(sort: \Decision.createdAt) private var decisions: [Decision]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Countdown insights
                    if let countdown = InsightService.insightCountdown(totalCheckIns: checkIns.count) {
                        CountdownCard(message: countdown.message, remaining: countdown.remaining)
                    }

                    // Courbe humeur 7 jours
                    weeklyMoodChart

                    // Courbe humeur 30 jours
                    monthlyMoodChart

                    // Corrélations
                    correlationsSection

                    // Heatmap 90 jours
                    heatmapSection

                    // Stats décisions
                    decisionStats
                }
                .padding(16)
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Weekly Mood Chart

    private var weeklyMoodChart: some View {
        let data = InsightService.dailyMoods(from: checkIns, days: 7)
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
                    AxisMarks(values: .stride(by: .day)) { value in
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
        let data = InsightService.dailyMoods(from: checkIns, days: 30)
        let hasData = data.contains { $0.averageScore > 0 }

        return StatsCard(title: "Humeur — 30 derniers jours", icon: "calendar") {
            if hasData {
                Chart(data) { entry in
                    LineMark(
                        x: .value("Jour", entry.date, unit: .day),
                        y: .value("Humeur", entry.averageScore)
                    )
                    .foregroundStyle(Color.blue)
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
        let correlations = InsightService.activityCorrelations(from: checkIns)
        let insightPhrase = InsightService.generateInsightPhrase(correlations: correlations)

        return StatsCard(title: "Corrélations", icon: "arrow.triangle.merge") {
            VStack(alignment: .leading, spacing: 12) {
                if let phrase = insightPhrase {
                    HStack(spacing: 8) {
                        PatchiView(expression: .proud, size: .small)
                        Text(phrase)
                            .font(.subheadline)
                            .italic()
                    }
                    .padding(.bottom, 4)
                }

                if correlations.isEmpty {
                    Text("Pas encore assez de données pour les corrélations.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(correlations.prefix(5)) { correlation in
                        HStack {
                            Image(systemName: correlation.activity.icon)
                                .font(.caption)
                                .frame(width: 20)
                            Text(correlation.activity.displayName)
                                .font(.caption)
                            Spacer()
                            MoodDots(score: correlation.averageMood)
                            Text(String(format: "%.1f", correlation.averageMood))
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Heatmap

    private var heatmapSection: some View {
        StatsCard(title: "Accountability — 90 jours", icon: "square.grid.3x3.fill") {
            let days = HeatmapService.generateHeatmap(from: accountabilityEntries)
            HeatmapWithLegend(days: days, showStats: true)
        }
    }

    // MARK: - Decision Stats

    private var decisionStats: some View {
        let pending = decisions.filter { $0.status == .pending }.count
        let reviewed = decisions.filter { $0.status != .pending }.count

        return StatsCard(title: "Décisions", icon: "arrow.triangle.branch") {
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Text("\(decisions.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Total")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                VStack(spacing: 4) {
                    Text("\(pending)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.orange)
                    Text("En attente")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                VStack(spacing: 4) {
                    Text("\(reviewed)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.green)
                    Text("Reviewées")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Helpers

    private var emptyChartPlaceholder: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.title2)
                .foregroundStyle(.tertiary)
            Text("Pas encore assez de données")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Stats Card

private struct StatsCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(.headline)

            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        }
    }
}

// MARK: - Countdown Card

private struct CountdownCard: View {
    let message: String
    let remaining: Int

    var body: some View {
        HStack(spacing: 12) {
            PatchiView(expression: .curious, size: .small)
            Text(message)
                .font(.subheadline)
            Spacer()
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.patchiOrange.opacity(0.08))
        }
    }
}

// MARK: - Mood Dots

private struct MoodDots: View {
    let score: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { i in
                Circle()
                    .fill(Double(i) <= score ? Color.mood(score: Int(score.rounded())) : Color(.systemGray5))
                    .frame(width: 6, height: 6)
            }
        }
    }
}
