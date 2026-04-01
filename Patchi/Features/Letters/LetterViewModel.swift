import SwiftUI
import SwiftData

@Observable
final class LetterViewModel {
    var content: String = ""
    var isSealed = false
    var isCompleted = false

    // Pour la lecture
    var isOpening = false
    var isOpened = false
    var replyText: String = ""

    var canSeal: Bool {
        content.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }

    func seal(context: ModelContext) {
        Haptics.success()
        let letter = FutureLetter(content: content.trimmingCharacters(in: .whitespacesAndNewlines))
        context.insert(letter)

        // Scheduler la notification 6 mois
        NotificationService.shared.scheduleLetterDelivery(
            letterId: letter.id,
            at: letter.deliverAt
        )

        isSealed = true
        isCompleted = true
    }

    func reply(to letter: FutureLetter, context: ModelContext) {
        let trimmed = replyText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Sauvegarder la réponse sur la lettre originale
        letter.reply = trimmed
        letter.repliedAt = Date()

        // Créer une nouvelle lettre pour dans 6 mois
        let newLetter = FutureLetter(content: trimmed)
        context.insert(newLetter)

        NotificationService.shared.scheduleLetterDelivery(
            letterId: newLetter.id,
            at: newLetter.deliverAt
        )

        isCompleted = true
    }

    /// Animation d'ouverture
    func openLetter() {
        isOpening = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.6)) {
                self.isOpened = true
            }
        }
    }

    func reset() {
        content = ""
        isSealed = false
        isCompleted = false
        isOpening = false
        isOpened = false
        replyText = ""
    }
}
