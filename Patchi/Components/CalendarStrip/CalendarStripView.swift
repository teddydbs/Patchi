import SwiftUI

struct CalendarStripView: View {
    @Binding var selectedDate: Date
    let markedDates: Set<Date>
    var days: Int = 30

    @State private var scrollTarget: Date?

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(calendarDays, id: \.self) { date in
                        CalendarDayCell(
                            date: date,
                            isSelected: date.isSameDay(as: selectedDate),
                            isToday: date.isToday,
                            hasEntry: markedDates.contains(where: { $0.isSameDay(as: date) })
                        )
                        .id(date)
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.2)) {
                                selectedDate = date
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .onAppear {
                proxy.scrollTo(selectedDate, anchor: .center)
            }
            .onChange(of: selectedDate) { _, newDate in
                withAnimation {
                    proxy.scrollTo(newDate, anchor: .center)
                }
            }
        }
        .frame(height: 72)
    }

    private var calendarDays: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<days).reversed().compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }
    }
}

// MARK: - Day Cell

private struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEntry: Bool

    var body: some View {
        VStack(spacing: 4) {
            // Jour de la semaine
            Text(dayOfWeek)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(isSelected ? .white : .secondary)

            // Numéro du jour
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(size: 16, weight: isToday ? .bold : .medium))
                .foregroundStyle(isSelected ? .white : (isToday ? .orange : .primary))

            // Point indicateur
            Circle()
                .fill(hasEntry ? (isSelected ? .white : .orange) : .clear)
                .frame(width: 5, height: 5)
        }
        .frame(width: 42, height: 62)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.patchiOrange : Color.clear)
        }
    }

    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(3)).capitalized
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var selected = Date()
        var body: some View {
            CalendarStripView(
                selectedDate: $selected,
                markedDates: Set([Date(), Date().daysAgo(1), Date().daysAgo(3)])
            )
        }
    }
    return PreviewWrapper()
}
