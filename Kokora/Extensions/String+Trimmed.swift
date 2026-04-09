import Foundation

extension String {
    /// Retourne la chaîne sans espaces ni retours à la ligne en début/fin.
    /// Raccourci pour `.trimmingCharacters(in: .whitespacesAndNewlines)`,
    /// utilisé systématiquement avant de valider une saisie utilisateur.
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// `true` si la chaîne une fois trimmée est vide (c.-à-d. uniquement des
    /// espaces/retours à la ligne, ou carrément vide).
    var isBlank: Bool {
        trimmed.isEmpty
    }
}
