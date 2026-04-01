import Foundation

/// Analyse les données utilisateur pour générer des corrélations et insights.
final class InsightService {
    static let shared = InsightService()
    private init() {}

    // MARK: - Mood par jour

    struct DailyMood: Identifiable {
        let id: Date
        let date: Date
        let averageScore: Double
    }

    /// Humeur moyenne par jour sur les N derniers jours
    static func dailyMoods(from checkIns: [CheckIn], days: Int = 7) -> [DailyMood] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<days).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let dayCheckIns = checkIns.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let average = dayCheckIns.isEmpty
                ? 0
                : Double(dayCheckIns.reduce(0) { $0 + $1.moodScore }) / Double(dayCheckIns.count)
            return DailyMood(id: date, date: date, averageScore: average)
        }
    }

    // MARK: - Corrélations activités / humeur

    struct ActivityCorrelation: Identifiable {
        let id: String
        let activity: Activity
        let averageMood: Double
        let count: Int
    }

    /// Corrélation entre activités et humeur moyenne
    static func activityCorrelations(from checkIns: [CheckIn]) -> [ActivityCorrelation] {
        var activityMoods: [Activity: (total: Int, count: Int)] = [:]

        for checkIn in checkIns {
            for activity in checkIn.activities {
                let current = activityMoods[activity, default: (0, 0)]
                activityMoods[activity] = (current.total + checkIn.moodScore, current.count + 1)
            }
        }

        return activityMoods
            .filter { $0.value.count >= 2 } // Au moins 2 occurrences
            .map { activity, data in
                ActivityCorrelation(
                    id: activity.rawValue,
                    activity: activity,
                    averageMood: Double(data.total) / Double(data.count),
                    count: data.count
                )
            }
            .sorted { $0.averageMood > $1.averageMood }
    }

    // MARK: - Activités les plus fréquentes

    struct ActivityFrequency: Identifiable {
        let id: String
        let activity: Activity
        let count: Int
    }

    static func topActivities(from checkIns: [CheckIn], limit: Int = 5) -> [ActivityFrequency] {
        var counts: [Activity: Int] = [:]
        for checkIn in checkIns {
            for activity in checkIn.activities {
                counts[activity, default: 0] += 1
            }
        }
        return counts
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { ActivityFrequency(id: $0.key.rawValue, activity: $0.key, count: $0.value) }
    }

    // MARK: - Insight phrases

    static func generateInsightPhrase(correlations: [ActivityCorrelation]) -> String? {
        guard let best = correlations.first, best.averageMood >= 3.5 else { return nil }
        return "Tu es souvent mieux quand tu fais \(best.activity.displayName.lowercased())."
    }

    // MARK: - Countdown insights

    static func insightCountdown(totalCheckIns: Int) -> (nextMilestone: Int, remaining: Int, message: String)? {
        let milestones = [
            (3, "Encore \(max(0, 3 - totalCheckIns)) check-ins avant tes premiers patterns."),
            (7, "Encore \(max(0, 7 - totalCheckIns)) check-ins avant ton insight semaine."),
            (30, "Encore \(max(0, 30 - totalCheckIns)) check-ins avant tes patterns complets."),
        ]

        for (target, message) in milestones {
            if totalCheckIns < target {
                return (target, target - totalCheckIns, message)
            }
        }
        return nil
    }
}
