import Foundation
import UserNotifications

/// Gère les 5 types de notifications locales de Patchi.
/// Soir (quotidien), Décision (rappels), J+30/J+90 (verdicts), Lettre (6 mois), Dimanche (rituel).
final class NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Permissions

    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func checkPermissionStatus() async -> UNAuthorizationStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - 1. Notifications du soir (quotidiennes)

    /// Ajoute une notification seulement si les permissions sont accordées
    private func addIfAuthorized(_ request: UNNotificationRequest) {
        center.getNotificationSettings { [center] settings in
            guard settings.authorizationStatus == .authorized else { return }
            center.add(request)
        }
    }

    /// Schedule les notifications quotidiennes du soir entre startHour et endHour
    func scheduleEveningNotifications(startHour: Int, endHour: Int, count: Int) {
        // Supprimer les anciennes
        removeNotifications(withPrefix: "evening-")

        for i in 0..<count {
            let hour: Int
            if count == 1 {
                hour = startHour
            } else {
                let range = endHour - startHour
                hour = startHour + (range * i) / max(count - 1, 1)
            }

            let phrase = eveningPhrases.randomElement() ?? "Comment tu te sens ce soir ?"

            var dateComponents = DateComponents()
            dateComponents.hour = hour
            dateComponents.minute = 0

            let content = makeContent(title: "Patchi", body: phrase)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "evening-\(i)",
                content: content,
                trigger: trigger
            )

            addIfAuthorized(request)
        }
    }

    // MARK: - 2. Notifications de décision (countdown)

    /// Schedule un rappel pour une décision à une date précise
    func scheduleDecisionReminder(decisionId: UUID, title: String, at date: Date, type: DecisionReminderType) {
        let daysLabel = type == .j30 ? "30 jours" : "90 jours"
        let body = "Ta décision sur \(title) — \(daysLabel). C'est l'heure du verdict."

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let content = makeContent(title: "Moment de vérité", body: body, categoryId: "DECISION_VERDICT")
        content.userInfo = [
            "decisionId": decisionId.uuidString,
            "type": type.rawValue
        ]

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = "decision-\(decisionId.uuidString)-\(type.rawValue)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        addIfAuthorized(request)
    }

    /// Supprime les notifications d'une décision
    func removeDecisionReminders(decisionId: UUID) {
        let identifiers = [
            "decision-\(decisionId.uuidString)-j30",
            "decision-\(decisionId.uuidString)-j90"
        ]
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    // MARK: - 3. Notification de lettre (6 mois)

    /// Schedule la notification de livraison d'une lettre
    func scheduleLetterDelivery(letterId: UUID, at date: Date) {
        let phrases = [
            "Quelqu'un t'a écrit. Tu le connais bien.",
            "Une lettre t'attendait.",
            "Un message du passé vient d'arriver.",
            "Toi d'il y a 6 mois a quelque chose à te dire.",
            "La lettre est arrivée. Elle t'attendait.",
        ]

        let content = makeContent(title: "Patchi", body: phrases.randomElement() ?? "Patchi est là.", categoryId: "LETTER_DELIVERY")
        content.userInfo = ["letterId": letterId.uuidString]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = "letter-\(letterId.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        addIfAuthorized(request)
    }

    /// Supprime la notification d'une lettre
    func removeLetterDelivery(letterId: UUID) {
        center.removePendingNotificationRequests(withIdentifiers: ["letter-\(letterId.uuidString)"])
    }

    // MARK: - 4. Notification du dimanche (rituel hebdo)

    /// Schedule la notification du rituel du dimanche à 19h
    func scheduleSundayRitual() {
        removeNotifications(withPrefix: "sunday-")

        let phrases = [
            "Le rituel de la semaine t'attend.",
            "Dimanche soir. On fait le bilan ?",
            "Ta semaine mérite un regard. Prends 5 minutes.",
            "Patchi t'attend pour le bilan de la semaine.",
            "C'est dimanche. Qu'est-ce que cette semaine t'a appris ?",
        ]

        var dateComponents = DateComponents()
        dateComponents.weekday = 1  // Dimanche
        dateComponents.hour = 19
        dateComponents.minute = 0

        let content = makeContent(title: "Rituel du dimanche", body: phrases.randomElement() ?? "Patchi est là.")
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "sunday-ritual", content: content, trigger: trigger)

        addIfAuthorized(request)
    }

    // MARK: - 5. Notification de décision en approche

    /// Schedule un rappel quelques jours avant un verdict
    func scheduleDecisionApproaching(decisionId: UUID, title: String, verdictDate: Date, daysBefore: Int = 2) {
        guard let reminderDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: verdictDate) else { return }
        guard reminderDate > Date() else { return }

        let body = "Ta décision sur \(title) — encore \(daysBefore) jours avant le verdict."
        let content = makeContent(title: "Patchi", body: body)
        content.userInfo = ["decisionId": decisionId.uuidString]

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = "decision-approaching-\(decisionId.uuidString)-\(daysBefore)d"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        addIfAuthorized(request)
    }

    // MARK: - Gestion

    /// Supprime toutes les notifications avec un préfixe donné
    func removeNotifications(withPrefix prefix: String) {
        center.getPendingNotificationRequests { requests in
            let identifiers = requests
                .filter { $0.identifier.hasPrefix(prefix) }
                .map(\.identifier)
            self.center.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    /// Supprime toutes les notifications Patchi
    func removeAllNotifications() {
        center.removeAllPendingNotificationRequests()
    }

    /// Nombre de notifications en attente
    func pendingCount() async -> Int {
        let requests = await center.pendingNotificationRequests()
        return requests.count
    }

    // MARK: - Private

    private func makeContent(title: String, body: String, categoryId: String? = nil) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        if let categoryId {
            content.categoryIdentifier = categoryId
        }
        return content
    }

    // MARK: - Pool de 20 phrases du soir

    private let eveningPhrases: [String] = [
        "Comment s'est passée ta journée ?",
        "Prends 2 minutes pour toi. Comment tu vas ?",
        "La journée touche à sa fin. Qu'est-ce que tu retiens ?",
        "Hé. Raconte-moi ta journée.",
        "Tu as pris le temps de regarder en toi aujourd'hui ?",
        "Ce soir, qu'est-ce qui te traverse l'esprit ?",
        "Une journée de plus. Comment elle était ?",
        "Avant de fermer les yeux, pose ce que tu portes.",
        "Qu'est-ce qui t'a marqué aujourd'hui ?",
        "Un mot pour décrire ta journée ?",
        "Tu es là. C'est le moment de faire le point.",
        "Ta journée mérite d'être notée. Même en deux mots.",
        "Ce soir, sois honnête avec toi-même.",
        "Qu'est-ce que tu aurais aimé faire différemment ?",
        "Patchi est là. Comment tu te sens ?",
        "Prends un instant. Juste pour toi.",
        "La journée est finie. Qu'est-ce qu'elle t'a appris ?",
        "Ce soir, qu'est-ce qui compte ?",
        "Tu mérites ces 2 minutes de réflexion.",
        "Avant de dormir, fais le point avec toi-même.",
    ]
}

// MARK: - Types

enum DecisionReminderType: String {
    case j30
    case j90
}
