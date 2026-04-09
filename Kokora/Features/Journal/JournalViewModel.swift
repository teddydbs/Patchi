import SwiftUI
import SwiftData

@Observable
final class JournalViewModel {
    var selectedDate: Date? = nil  // nil = toutes les entrées
    var selectedFilter: JournalFilter = .all
    var showAllEntries: Bool = true  // true par défaut = chronologique

    enum JournalFilter: String, CaseIterable, Identifiable {
        case all
        case checkIns
        case accountability
        case decisions
        case letters

        var id: String { rawValue }

        var label: String {
            switch self {
            case .all: "Tout"
            case .checkIns: "Check-ins"
            case .accountability: "Accountability"
            case .decisions: "Décisions"
            case .letters: "Lettres"
            }
        }
    }

    /// Dates qui ont au moins une entrée (pour les points du calendrier)
    func markedDates(
        checkIns: [CheckIn],
        accountabilityEntries: [AccountabilityEntry],
        decisions: [Decision],
        letters: [FutureLetter]
    ) -> Set<Date> {
        var dates = Set<Date>()
        for c in checkIns { dates.insert(Calendar.current.startOfDay(for: c.date)) }
        for a in accountabilityEntries { dates.insert(Calendar.current.startOfDay(for: a.date)) }
        for d in decisions { dates.insert(Calendar.current.startOfDay(for: d.createdAt)) }
        for l in letters { dates.insert(Calendar.current.startOfDay(for: l.writtenAt)) }
        return dates
    }

    /// Compteurs
    func counts(
        checkIns: [CheckIn],
        accountabilityEntries: [AccountabilityEntry],
        decisions: [Decision],
        letters: [FutureLetter]
    ) -> (reflections: Int, checkIns: Int, photos: Int) {
        let totalCheckIns = checkIns.count
        let totalReflections = totalCheckIns + accountabilityEntries.count + decisions.count
        let totalPhotos = checkIns.filter { $0.photoData != nil }.count
        return (totalReflections, totalCheckIns, totalPhotos)
    }
}
