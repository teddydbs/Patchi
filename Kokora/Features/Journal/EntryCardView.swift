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
        case .decision: "Decision"
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
        case .checkIn: .mdPurple
        case .accountability: .mdGreen
        case .decision: .mdYellow
        case .letter: .mdOrange
        }
    }
}

// MARK: - Mood Image Helper

private func moodImageName(score: Int) -> String {
    switch score {
    case 5: return "emotion_heureux"
    case 4: return "emotion_serein"
    case 3: return "emotion_nostalgique"
    case 2: return "emotion_triste"
    case 1: return "emotion_seul"
    default: return "emotion_serein"
    }
}

// MARK: - Check-in Card

struct CheckInCardView: View {
    let checkIn: CheckIn

    var body: some View {
        HStack(spacing: 14) {
            // Mood Kokora image
            Image(moodImageName(score: checkIn.moodScore))
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Label("Check-in", systemImage: "face.smiling")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.mdTextGray)
                    Spacer()
                    Text(checkIn.date.formattedShort)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.mdTextLight)
                }

                if let title = checkIn.title, !title.isEmpty {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.mdTextBlack)
                } else {
                    Text("Humeur : \(checkIn.moodScore)/5")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.mdTextBlack)
                }

                if !checkIn.activities.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(checkIn.activities.prefix(5)) { activity in
                            Image(systemName: activity.icon)
                                .font(.caption2)
                                .foregroundStyle(Color.mdTextGray)
                        }
                        if checkIn.activities.count > 5 {
                            Text("+\(checkIn.activities.count - 5)")
                                .font(.caption2)
                                .foregroundStyle(Color.mdTextGray)
                        }
                    }
                }

                if let reformulation = checkIn.reformulation {
                    Text(reformulation)
                        .font(.system(size: 13, weight: .medium))
                        .italic()
                        .foregroundStyle(Color.mdTextGray)
                        .lineLimit(1)
                }
            }

            if let photoData = checkIn.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.moodVivid(checkIn.moodScore).opacity(0.15))
        )
    }
}

// MARK: - Decision Card

struct DecisionCardView: View {
    let decision: Decision

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label("Decision", systemImage: "arrow.triangle.branch")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.mdTextGray)
                Spacer()
                StatusBadge(status: decision.status)
            }

            Text(decision.title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.mdTextBlack)

            HStack(spacing: 4) {
                ForEach(0..<decision.importance, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(Color.mdYellow)
                }
                Spacer()
                Text(decision.createdAt.formattedShort)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.mdTextLight)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.mdPurpleBg)
        )
    }
}

// MARK: - Status Badge

private struct StatusBadge: View {
    let status: DecisionStatus

    var body: some View {
        Text(status.displayName)
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule(style: .continuous).fill(badgeColor.opacity(0.15)))
            .foregroundStyle(badgeColor)
    }

    private var badgeColor: Color {
        switch status {
        case .pending: .mdYellow
        case .reviewed30: .mdPurple
        case .reviewed90: .mdGreen
        }
    }
}

// MARK: - Accountability Card

struct AccountabilityCardView: View {
    let entry: AccountabilityEntry

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(entry.heatmapColor.color)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Label("Accountability", systemImage: "checkmark.square")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.mdTextGray)
                    Spacer()
                    Text(entry.date.formattedShort)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.mdTextLight)
                }

                if entry.isSkipped {
                    Text("Tout allait bien")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.mdGreen)
                } else {
                    Text(entry.missedAction)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color.mdTextBlack)
                        .lineLimit(2)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.mdGreenBg)
        )
    }
}

// MARK: - Letter Card

struct LetterCardView: View {
    let letter: FutureLetter

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label("Lettre", systemImage: "envelope.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.mdTextGray)
                Spacer()

                if letter.isDelivered {
                    Text("Livree")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.mdGreen)
                } else if letter.deliverAt.daysSinceNow > 0 {
                    Text("Dans \(letter.deliverAt.daysSinceNow)j")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.mdYellow)
                } else {
                    Text("Prete")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.mdGreen)
                }
            }

            Text(letter.isDelivered ? letter.content : "Lettre scellee")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color.mdTextBlack)
                .lineLimit(2)
                .redacted(reason: letter.isDelivered ? [] : .placeholder)

            Text("Ecrite le \(letter.writtenAt.formattedShort)")
                .font(.system(size: 11))
                .foregroundStyle(Color.mdTextLight)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.mdOrangeBg)
        )
    }
}
