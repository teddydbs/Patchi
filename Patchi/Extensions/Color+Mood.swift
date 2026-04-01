import SwiftUI

extension Color {
    /// Couleur de fond vive selon le score d'humeur (1-5)
    static func mood(score: Int) -> Color {
        switch score {
        case 1: Color(red: 0.1, green: 0.12, blue: 0.35)   // Bleu nuit profond
        case 2: Color(red: 0.55, green: 0.35, blue: 0.7)    // Violet doux
        case 3: Color(red: 0.92, green: 0.85, blue: 0.7)    // Beige chaud
        case 4: Color(red: 0.1, green: 0.75, blue: 0.5)     // Vert émeraude franc
        case 5: Color(red: 1.0, green: 0.85, blue: 0.15)    // Jaune soleil vif
        default: Color(red: 0.92, green: 0.85, blue: 0.7)   // Beige par défaut
        }
    }

    /// Couleur pour les émotions spéciales (hors échelle 1-5)
    static let moodStressed = Color(red: 1.0, green: 0.55, blue: 0.15)  // Orange vif
    static let moodAngry = Color(red: 0.95, green: 0.35, blue: 0.35)    // Rouge corail

    /// Couleur de texte adaptée au fond d'humeur
    static func moodText(score: Int) -> Color {
        switch score {
        case 1, 2: .white
        default: Color(red: 0.15, green: 0.15, blue: 0.15)
        }
    }

    /// Couleurs des catégories de citations
    static let quoteCourage = Color(red: 1.0, green: 0.55, blue: 0.15)
    static let quoteDecision = Color(red: 0.3, green: 0.5, blue: 0.85)
    static let quoteSoi = Color(red: 0.55, green: 0.35, blue: 0.7)
    static let quoteRelations = Color(red: 0.9, green: 0.4, blue: 0.55)
    static let quoteTravail = Color(red: 0.1, green: 0.75, blue: 0.5)
    static let quoteNature = Color(red: 0.2, green: 0.7, blue: 0.45)

    /// Orange Patchi
    static let patchiOrange = Color(red: 1.0, green: 0.6, blue: 0.2)
}
