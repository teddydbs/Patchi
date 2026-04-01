import SwiftUI

struct HeatmapGridView: View {
    let days: [HeatmapService.HeatmapDay]
    var columns: Int = 13
    var animated: Bool = true

    @State private var visibleCount = 0

    private let cellSpacing: CGFloat = 3

    var body: some View {
        let rows = Int(ceil(Double(days.count) / Double(columns)))

        VStack(spacing: cellSpacing) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: cellSpacing) {
                    ForEach(0..<columns, id: \.self) { col in
                        let index = row * columns + col
                        if index < days.count {
                            HeatmapCell(
                                day: days[index],
                                isVisible: !animated || index < visibleCount
                            )
                        } else {
                            Color.clear
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
            }
        }
        .onAppear {
            if animated {
                animateCells()
            } else {
                visibleCount = days.count
            }
        }
    }

    private func animateCells() {
        visibleCount = 0
        let totalCells = days.count
        for i in 0..<totalCells {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.015) {
                withAnimation(.easeOut(duration: 0.2)) {
                    visibleCount = i + 1
                }
            }
        }
    }
}

// MARK: - Cell

struct HeatmapCell: View {
    let day: HeatmapService.HeatmapDay
    let isVisible: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(cellColor)
            .aspectRatio(1, contentMode: .fit)
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.5)
    }

    private var cellColor: Color {
        guard isVisible else { return .clear }

        if day.isEmpty {
            return Color(.systemGray5)
        }

        guard let color = day.color else {
            return Color(.systemGray5)
        }

        return color.color.opacity(day.opacity)
    }
}

// MARK: - Heatmap with Legend

struct HeatmapWithLegend: View {
    let days: [HeatmapService.HeatmapDay]
    var showStats: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeatmapGridView(days: days)

            // Légende
            HStack(spacing: 16) {
                ForEach(HeatmapColor.allCases, id: \.rawValue) { color in
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(color.color)
                            .frame(width: 10, height: 10)
                        Text(color.label)
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Stats optionnelles
            if showStats {
                let stats = HeatmapService.computeStats(from: days)
                HStack(spacing: 20) {
                    StatBadge(value: "\(stats.filledDays)", label: "jours")
                    StatBadge(value: "\(stats.greenDays)", label: "réussis")
                    StatBadge(value: "\(stats.currentStreak)", label: "streak")
                }
            }
        }
    }
}

private struct StatBadge: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview("Heatmap 90 jours") {
    let sampleDays: [HeatmapService.HeatmapDay] = (0..<90).map { i in
        let date = Calendar.current.date(byAdding: .day, value: -89 + i, to: Date())!
        let isEmpty = Int.random(in: 0...3) == 0
        let colors: [HeatmapColor] = [.red, .orange, .lightGreen, .darkGreen]
        return HeatmapService.HeatmapDay(
            id: date,
            date: date,
            color: isEmpty ? nil : colors.randomElement(),
            importance: Int.random(in: 1...5),
            isEmpty: isEmpty
        )
    }

    ScrollView {
        HeatmapWithLegend(days: sampleDays)
            .padding()
    }
}
