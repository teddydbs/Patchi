import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: self) ?? self
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: self) ?? self
    }

    var plus30Days: Date {
        Calendar.current.date(byAdding: .day, value: 30, to: self) ?? self
    }

    var plus90Days: Date {
        Calendar.current.date(byAdding: .day, value: 90, to: self) ?? self
    }

    var plus6Months: Date {
        Calendar.current.date(byAdding: .month, value: 6, to: self) ?? self
    }

    var daysUntilNow: Int {
        Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
    }

    var daysSinceNow: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: self).day ?? 0
    }

    /// Format "Lundi 1 avril" (année courante) ou "Lundi 1 avril 2025" (autre année)
    var formattedLong: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        let currentYear = Calendar.current.component(.year, from: Date())
        let selfYear = Calendar.current.component(.year, from: self)
        formatter.dateFormat = currentYear == selfYear ? "EEEE d MMMM" : "EEEE d MMMM yyyy"
        return formatter.string(from: self).capitalized
    }

    /// Format "1 avr." (année courante) ou "1 avr. 2025" (autre année)
    var formattedShort: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        let currentYear = Calendar.current.component(.year, from: Date())
        let selfYear = Calendar.current.component(.year, from: self)
        formatter.dateFormat = currentYear == selfYear ? "d MMM" : "d MMM yyyy"
        return formatter.string(from: self)
    }

    /// Format "Aujourd'hui" / "Hier" / date
    var formattedRelative: String {
        if isToday { return "Aujourd'hui" }
        if isYesterday { return "Hier" }
        return formattedLong
    }

    /// Weekday: 1=Dimanche
    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }

    var isSunday: Bool {
        weekday == 1
    }
}
