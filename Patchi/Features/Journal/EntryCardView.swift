import SwiftUI

/// Type d'entree unifie pour le journal
enum JournalEntryType: String, CaseIterable, Identifiable {
    case checkIn
    case accountability
    case decision
    case letter

    var id: String { rawValue }

    var label: String {
        switch self {
        case .checkIn: "Check-in"
        case .accountability: "Accountability"
        case .decision: "Décision"
        case .letter: "Lettre"
        }
    }

    var icon: String {
        switch self {
        case .checkIn: "face.smiling"
        case .accountability: "checkmark.square"
        case .decision: "arrow.triangle.branch"
        case .letter: "envelope.fill"
        }
    }

    var color: Color {
        switch self {
        case .checkIn: .accentPurple
        case .accountability: .dsSuccess
        case .decision: .accentAmber
        case .letter: .patchiOrange
        }
    }
}

// MARK: - Check-in Card

struct CheckInCardView: View {
    let checkIn: CheckIn

    var body: some View {
        ClayCard(tint: Color.mood(score: checkIn.moodScore)) {
            HStack(spacing: 14) {
                // Mood circle
                ZStack {
                    Circle()
                        .fill(Color.mood(score: checkIn.moodScore))
                        .frame(width: 40, height: 40)
                    Text("\(checkIn.moodScore)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.moodText(score: checkIn.moodScore))
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Label("Check-in", systemImage: "face.smiling")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.dsTextSecondary)
                        Spacer()
                        Text(checkIn.date.formattedShort)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.dsTextSecondary)
                    }

                    if let title = checkIn.title, !title.isEmpty {
                        Text(title)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.dsTextPrimary)
                    } else {
                        Text("Humeur : \(checkIn.moodScore)/5")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.dsTextPrimary)
                    }

                    if !checkIn.activities.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(checkIn.activities.prefix(5)) { activity in
                                Image(systemName: activity.icon)
                                    .font(.caption2)
                                    .foregroundStyle(Color.dsTextSecondary)
                            }
                            if checkIn.activities.count > 5 {
                                Text("+\(checkIn.activities.count - 5)")
                                    .font(.caption2)
                                    .foregroundStyle(Color.dsTextSecondary)
                            }
                        }
                    }

                    if let reformulation = checkIn.reformulation {
                        Text(reformulation)
                            .font(.patchiBody(13))
                            .italic()
                            .foregroundStyle(Color.dsTextSecondary)
                            .lineLimit(1)
                    }
                }

                if let photoData = checkIn.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.chip / 2, style: .continuous))
                }
            }
        }
    }
}

// MARK: - Decision Card

struct DecisionCardView: View {
    let decision: Decision

    var body: some View {
        ClayCard(tint: .accentPurple) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Décision", systemImage: "arrow.triangle.branch")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.dsTextSecondary)
                    Spacer()
                    StatusBadge(status: decision.status)
                }

                Text(decision.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.dsTextPrimary)

                HStack(spacing: 4) {
                    ForEach(0..<decision.importance, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(Color.accentAmber)
                    }
                    Spacer()
                    Text(decision.createdAt.formattedShort)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.dsTextSecondary)
                }
            }
        }
    }
}

private struct StatusBadge: View {
    let status: DecisionStatus

    var body: some View {
        Text(status.displayName)
            .font(.system(size: 10, weight: .semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule(style: .continuous).fill(badgeColor.opacity(0.15)))
            .foregroundStyle(badgeColor)
    }

    private var badgeColor: Color {
        switch status {
        case .pending: .accentAmber
        case .reviewed30: .accentPurple
        case .reviewed90: .dsSuccess
        }
    }
}

// MARK: - Accountability Card

struct AccountabilityCardView: View {
    let entry: AccountabilityEntry

    var body: some View {
        ClayCard(tint: .dsSuccess) {
            HStack(spacing: 14) {
                Circle()
                    .fill(entry.heatmapColor.color)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Label("Accountability", systemImage: "checkmark.square")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Color.dsTextSecondary)
                        Spacer()
                        Text(entry.date.formattedShort)
                            .font(.system(size: 11))
                            .foregroundStyle(Color.dsTextSecondary)
                    }

                    if entry.isSkipped {
                        Text("Tout allait bien")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.dsSuccess)
                    } else {
                        Text(entry.missedAction)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color.dsTextPrimary)
                            .lineLimit(2)
                    }
                }
            }
        }
    }
}

// MARK: - Letter Card

struct LetterCardView: View {
    let letter: FutureLetter

    var body: some View {
        ClayCard(tint: .patchiOrange) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Lettre", systemImage: "envelope.fill")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Color.dsTextSecondary)
                    Spacer()

                    if letter.isDelivered {
                        Text("Livree")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.dsSuccess)
                    } else if letter.deliverAt.daysSinceNow > 0 {
                        Text("Dans \(letter.deliverAt.daysSinceNow)j")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.accentAmber)
                    } else {
                        Text("Prête")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.dsSuccess)
                    }
                }

                Text(letter.isDelivered ? letter.content : "Lettre scellée")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.dsTextPrimary)
                    .lineLimit(2)
                    .redacted(reason: letter.isDelivered ? [] : .placeholder)

                Text("Écrite le \(letter.writtenAt.formattedShort)")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.dsTextSecondary)
            }
        }
    }
}
