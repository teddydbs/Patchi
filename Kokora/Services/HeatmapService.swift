import Foundation
import SwiftData

/// Calcule les données de la heatmap 90 jours à partir des AccountabilityEntry.
final class HeatmapService {
    /// Représente un jour sur la heatmap
    struct HeatmapDay: Identifiable {
        let id: Date
        let date: Date
        let color: HeatmapColor?
        let importance: Int
        let isEmpty: Bool

        var opacity: Double {
            guard !isEmpty else { return 0.15 }
            // Intensité basée sur l'importance (1-5)
            return 0.4 + (Double(importance) / 5.0) * 0.6
        }
    }

    /// Génère les 90 derniers jours de heatmap
    static func generateHeatmap(from entries: [AccountabilityEntry], days: Int = 90) -> [HeatmapDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Créer un dictionnaire date → entry pour lookup rapide
        var entryMap: [Date: AccountabilityEntry] = [:]
        for entry in entries {
            let dayStart = calendar.startOfDay(for: entry.date)
            entryMap[dayStart] = entry
        }

        // Générer les jours
        var heatmapDays: [HeatmapDay] = []
        for dayOffset in (0..<days).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }

            if let entry = entryMap[date] {
                heatmapDays.append(HeatmapDay(
                    id: date,
                    date: date,
                    color: entry.heatmapColor,
                    importance: entry.importance,
                    isEmpty: false
                ))
            } else {
                heatmapDays.append(HeatmapDay(
                    id: date,
                    date: date,
                    color: nil,
                    importance: 0,
                    isEmpty: true
                ))
            }
        }

        return heatmapDays
    }

    /// Stats résumées de la heatmap
    struct HeatmapStats {
        let totalDays: Int
        let filledDays: Int
        let greenDays: Int
        let redDays: Int
        let currentStreak: Int
        let longestStreak: Int
    }

    static func computeStats(from days: [HeatmapDay]) -> HeatmapStats {
        let filled = days.filter { !$0.isEmpty }
        let green = filled.filter { $0.color == .lightGreen || $0.color == .darkGreen }
        let red = filled.filter { $0.color == .red }

        // Streaks (jours consécutifs remplis en partant d'aujourd'hui)
        var currentStreak = 0
        for day in days.reversed() {
            if !day.isEmpty {
                currentStreak += 1
            } else {
                break
            }
        }

        // Plus long streak
        var longestStreak = 0
        var streak = 0
        for day in days {
            if !day.isEmpty {
                streak += 1
                longestStreak = max(longestStreak, streak)
            } else {
                streak = 0
            }
        }

        return HeatmapStats(
            totalDays: days.count,
            filledDays: filled.count,
            greenDays: green.count,
            redDays: red.count,
            currentStreak: currentStreak,
            longestStreak: longestStreak
        )
    }
}
