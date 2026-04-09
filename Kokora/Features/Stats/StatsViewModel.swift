import SwiftUI

@Observable
final class StatsViewModel {
    // MARK: - Computed Data

    /// Humeur moyenne par jour sur 7 jours
    func weeklyMoods(from checkIns: [CheckIn]) -> [InsightService.DailyMood] {
        InsightService.dailyMoods(from: checkIns, days: 7)
    }

    /// Humeur moyenne par jour sur 30 jours
    func monthlyMoods(from checkIns: [CheckIn]) -> [InsightService.DailyMood] {
        InsightService.dailyMoods(from: checkIns, days: 30)
    }

    /// Corrélations activités / humeur
    func correlations(from checkIns: [CheckIn]) -> [InsightService.ActivityCorrelation] {
        InsightService.activityCorrelations(from: checkIns)
    }

    /// Phrase d'insight générée à partir des corrélations
    func insightPhrase(from checkIns: [CheckIn]) -> String? {
        let correlations = correlations(from: checkIns)
        return InsightService.generateInsightPhrase(correlations: correlations)
    }

    /// Countdown vers le prochain milestone
    func countdown(totalCheckIns: Int) -> (message: String, remaining: Int)? {
        guard let result = InsightService.insightCountdown(totalCheckIns: totalCheckIns) else { return nil }
        return (message: result.message, remaining: result.remaining)
    }

    /// Heatmap 90 jours
    func heatmapDays(from entries: [AccountabilityEntry]) -> [HeatmapService.HeatmapDay] {
        HeatmapService.generateHeatmap(from: entries)
    }

    /// Stats décisions
    func decisionCounts(from decisions: [Decision]) -> (total: Int, pending: Int, reviewed: Int) {
        let pending = decisions.filter { $0.status == .pending }.count
        let reviewed = decisions.filter { $0.status != .pending }.count
        return (decisions.count, pending, reviewed)
    }
}
