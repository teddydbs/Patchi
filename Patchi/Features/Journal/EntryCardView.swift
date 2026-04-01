import SwiftUI

/// Type d'entrée unifié pour le journal
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
        case .checkIn: .blue
        case .accountability: .green
        case .decision: .purple
        case .letter: .orange
        }
    }
}

// MARK: - Check-in Card

struct CheckInCardView: View {
    let checkIn: CheckIn

    var body: some View {
        HStack(spacing: 14) {
            // Indicateur couleur humeur
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.mood(score: checkIn.moodScore))
                .frame(width: 6)

            VStack(alignment: .leading, spacing: 6) {
                // Header
                HStack {
                    Label("Check-in", systemImage: "face.smiling")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(checkIn.date.formattedShort)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                // Titre ou mood
                if let title = checkIn.title, !title.isEmpty {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                } else {
                    Text("Humeur : \(checkIn.moodScore)/5")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                // Activités
                if !checkIn.activities.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(checkIn.activities.prefix(5)) { activity in
                            Image(systemName: activity.icon)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        if checkIn.activities.count > 5 {
                            Text("+\(checkIn.activities.count - 5)")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                // Reformulation
                if let reformulation = checkIn.reformulation {
                    Text(reformulation)
                        .font(.caption)
                        .italic()
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            // Photo thumbnail
            if let photoData = checkIn.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        }
    }
}

// MARK: - Decision Card

struct DecisionCardView: View {
    let decision: Decision

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.purple)
                .frame(width: 6)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Décision", systemImage: "arrow.triangle.branch")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    StatusBadge(status: decision.status)
                }

                Text(decision.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                HStack(spacing: 4) {
                    ForEach(0..<decision.importance, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.orange)
                    }
                    Spacer()
                    Text(decision.createdAt.formattedShort)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        }
    }
}

private struct StatusBadge: View {
    let status: DecisionStatus

    var body: some View {
        Text(status.displayName)
            .font(.system(size: 10, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background {
                Capsule().fill(badgeColor.opacity(0.15))
            }
            .foregroundStyle(badgeColor)
    }

    private var badgeColor: Color {
        switch status {
        case .pending: .orange
        case .reviewed30: .blue
        case .reviewed90: .green
        }
    }
}

// MARK: - Accountability Card

struct AccountabilityCardView: View {
    let entry: AccountabilityEntry

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 4)
                .fill(entry.heatmapColor.color)
                .frame(width: 6)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Accountability", systemImage: "checkmark.square")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(entry.date.formattedShort)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                if entry.isSkipped {
                    Text("Tout allait bien")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.green)
                } else {
                    Text(entry.missedAction)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                }
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        }
    }
}

// MARK: - Letter Card

struct LetterCardView: View {
    let letter: FutureLetter

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.orange)
                .frame(width: 6)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Lettre", systemImage: "envelope.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()

                    if letter.isDelivered {
                        Text("Livrée")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.green)
                    } else {
                        Text("Dans \(letter.deliverAt.daysSinceNow)j")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.orange)
                    }
                }

                Text(letter.isDelivered ? letter.content : "Lettre scellée")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .redacted(reason: letter.isDelivered ? [] : .placeholder)

                Text("Écrite le \(letter.writtenAt.formattedShort)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
        }
    }
}
