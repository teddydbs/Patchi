import SwiftUI
import SwiftData

@Observable
final class HomeViewModel {
    // MARK: - Daily Challenge

    var isDailyChallengeCompleted: Bool {
        get {
            guard let dateString = UserDefaults.standard.string(forKey: "dailyChallengeCompletedDate") else { return false }
            let todayString = Self.dateKeyFormatter.string(from: Date())
            return dateString == todayString
        }
        set {
            if newValue {
                UserDefaults.standard.set(Self.dateKeyFormatter.string(from: Date()), forKey: "dailyChallengeCompletedDate")
            } else {
                UserDefaults.standard.removeObject(forKey: "dailyChallengeCompletedDate")
            }
        }
    }

    private static let dateKeyFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private var cachedChallenge: DailyChallenge?
    private var challengeDate: Date?

    /// Retourne un défi stable pour la journée (ne change pas à chaque render)
    func dailyChallenge(recentActivities: [Activity]) -> DailyChallenge {
        let today = Calendar.current.startOfDay(for: Date())

        // Si on a déjà un défi pour aujourd'hui, le retourner
        if let cached = cachedChallenge, challengeDate == today {
            return cached
        }

        // Générer un nouveau défi déterministe basé sur le jour
        let seed = Calendar.current.ordinality(of: .day, in: .era, for: today) ?? 0
        let relevantChallenges = recentActivities.flatMap { challengesForActivity($0) }
        let allOptions = relevantChallenges.isEmpty ? genericChallenges : relevantChallenges

        let index = seed % allOptions.count
        let challenge = allOptions[index]

        cachedChallenge = challenge
        challengeDate = today
        return challenge
    }

    /// Temps restant jusqu'à minuit
    var timeUntilMidnight: String {
        let calendar = Calendar.current
        let now = Date()
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now)) else {
            return ""
        }
        let components = calendar.dateComponents([.hour, .minute], from: now, to: tomorrow)
        return "\(components.hour ?? 0)h\(String(format: "%02d", components.minute ?? 0))"
    }

    // MARK: - Patchi expression

    func patchiExpression(latestMood: Int?) -> PatchiExpression {
        guard let mood = latestMood else { return .neutral }
        let hour = Calendar.current.component(.hour, from: Date())

        if hour >= 23 || hour < 6 {
            return .sleeping
        }

        return PatchiExpression.fromMoodScore(mood)
    }

    // MARK: - Data helpers

    /// Décisions en attente de verdict
    func pendingDecisions(from decisions: [Decision]) -> [Decision] {
        decisions.filter { $0.status == .pending }
    }

    /// Vérifie si un check-in existe pour un jour donné
    func hasMoodEntry(on date: Date, in checkIns: [CheckIn]) -> Bool {
        checkIns.contains { $0.date.isSameDay(as: date) }
    }

    /// Score d'humeur pour un jour donné
    func moodScore(on date: Date, in checkIns: [CheckIn]) -> Int? {
        checkIns.first { $0.date.isSameDay(as: date) }?.moodScore
    }

    /// Couleur du dot pour un jour (basée sur l'humeur ou clear)
    func dotColor(for date: Date, in checkIns: [CheckIn]) -> Color {
        if let mood = moodScore(on: date, in: checkIns) {
            return Color.mood(score: mood)
        }
        return .clear
    }

    /// Lettre du jour de la semaine (L, M, M, J, V, S, D)
    func dayLetter(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.dateFormat = "EEEEE"
        return formatter.string(from: date).uppercased()
    }

    /// Prénom de l'utilisateur courant
    func currentUserName(from users: [User]) -> String? {
        users.first?.firstName
    }

    // MARK: - Challenges data

    struct DailyChallenge: Identifiable {
        let id = UUID()
        let text: String
        let icon: String
    }

    private func challengesForActivity(_ activity: Activity) -> [DailyChallenge] {
        switch activity {
        case .sport:
            [DailyChallenge(text: "Marche 15 minutes aujourd'hui.", icon: "figure.walk"),
             DailyChallenge(text: "Fais 10 minutes d'étirements.", icon: "figure.flexibility")]
        case .famille:
            [DailyChallenge(text: "Appelle quelqu'un de ta famille.", icon: "phone.fill"),
             DailyChallenge(text: "Envoie un message à un proche.", icon: "message.fill")]
        case .lecture:
            [DailyChallenge(text: "Lis 10 pages de n'importe quel livre.", icon: "book.fill"),
             DailyChallenge(text: "Découvre un article qui t'inspire.", icon: "doc.text.fill")]
        case .meditation:
            [DailyChallenge(text: "Prends 5 minutes pour ne rien faire.", icon: "brain.head.profile.fill"),
             DailyChallenge(text: "3 respirations profondes. Maintenant.", icon: "wind")]
        case .nature:
            [DailyChallenge(text: "Sors prendre l'air 10 minutes.", icon: "leaf.fill"),
             DailyChallenge(text: "Observe le ciel pendant 2 minutes.", icon: "cloud.sun.fill")]
        case .amis:
            [DailyChallenge(text: "Propose un café à quelqu'un.", icon: "cup.and.saucer.fill"),
             DailyChallenge(text: "Envoie un message à un ami que tu n'as pas vu.", icon: "person.2.fill")]
        case .musique:
            [DailyChallenge(text: "Écoute un album en entier.", icon: "music.note"),
             DailyChallenge(text: "Découvre un artiste que tu ne connais pas.", icon: "headphones")]
        case .cuisine:
            [DailyChallenge(text: "Cuisine quelque chose de nouveau.", icon: "fork.knife"),
             DailyChallenge(text: "Prépare ton repas avec soin.", icon: "flame.fill")]
        default:
            []
        }
    }

    private let genericChallenges = [
        DailyChallenge(text: "Bois un grand verre d'eau. Maintenant.", icon: "drop.fill"),
        DailyChallenge(text: "Écris 3 choses pour lesquelles tu es reconnaissant.", icon: "heart.fill"),
        DailyChallenge(text: "Range un espace de ton environnement.", icon: "sparkles"),
        DailyChallenge(text: "Fais une chose que tu repousses depuis longtemps.", icon: "arrow.right.circle.fill"),
        DailyChallenge(text: "Dis merci à quelqu'un aujourd'hui.", icon: "hand.wave.fill"),
        DailyChallenge(text: "Éteins ton téléphone pendant 30 minutes.", icon: "iphone.slash"),
        DailyChallenge(text: "Fais quelque chose qui te fait sourire.", icon: "face.smiling"),
        DailyChallenge(text: "Prends une photo de quelque chose de beau.", icon: "camera.fill"),
    ]
}
