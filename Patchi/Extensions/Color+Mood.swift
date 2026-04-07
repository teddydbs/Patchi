import SwiftUI

// MARK: - Design System Tokens

extension Color {

    // MARK: Mood Colors

    /// Couleur de fond vive selon le score d'humeur (1-5)
    static func mood(score: Int) -> Color {
        switch score {
        case 1: Color(red: 0.1, green: 0.12, blue: 0.35)   // Bleu nuit profond
        case 2: Color(red: 0.55, green: 0.35, blue: 0.7)    // Violet doux
        case 3: Color(red: 0.92, green: 0.85, blue: 0.7)    // Beige chaud
        case 4: Color(red: 0.1, green: 0.75, blue: 0.5)     // Vert émeraude franc
        case 5: Color(red: 1.0, green: 0.85, blue: 0.15)    // Jaune soleil vif
        default: Color(red: 0.92, green: 0.85, blue: 0.7)
        }
    }

    static let moodStressed = Color(red: 1.0, green: 0.55, blue: 0.15)
    static let moodAngry = Color(red: 0.95, green: 0.35, blue: 0.35)

    /// Couleur de texte adaptée au fond d'humeur
    static func moodText(score: Int) -> Color {
        switch score {
        case 1, 2: .white
        case 3: Color(red: 0.2, green: 0.2, blue: 0.2)
        default: Color(red: 0.1, green: 0.1, blue: 0.1)
        }
    }

    // MARK: Quote Colors

    static let quoteCourage = Color(red: 1.0, green: 0.55, blue: 0.15)
    static let quoteDecision = Color(red: 0.3, green: 0.5, blue: 0.85)
    static let quoteSoi = Color(red: 0.55, green: 0.35, blue: 0.7)
    static let quoteRelations = Color(red: 0.9, green: 0.4, blue: 0.55)
    static let quoteTravail = Color(red: 0.1, green: 0.75, blue: 0.5)
    static let quoteNature = Color(red: 0.2, green: 0.7, blue: 0.45)

    // MARK: Brand

    static let patchiOrange = Color(red: 1.0, green: 0.6, blue: 0.2)

    // MARK: Semantic Tokens (Claymorphism Design System)

    /// Accent violet — insights, stats, premium
    static let accentPurple = Color(red: 0.486, green: 0.228, blue: 0.929)  // #7C3AED

    /// Accent ambre — streaks, badges
    static let accentAmber = Color(red: 0.851, green: 0.467, blue: 0.024)   // #D97706

    /// Succès — confirmations
    static let dsSuccess = Color(red: 0.020, green: 0.588, blue: 0.412)     // #059669

    /// Destructif — suppression, danger
    static let dsDestructive = Color(red: 0.863, green: 0.149, blue: 0.149) // #DC2626

    /// Fond principal — crème chaud (light) / brun nuit (dark)
    static let dsBackground = Color("dsBackground")

    /// Fond de card glass-clay
    static let dsCard = Color("dsCard")

    /// Texte principal
    static let dsTextPrimary = Color("dsTextPrimary")

    /// Texte secondaire
    static let dsTextSecondary = Color("dsTextSecondary")

    /// Bordure subtile
    static let dsBorder = Color("dsBorder")

    // MARK: Legacy aliases

    static let cardBackground = dsCard
    static let pageBackground = dsBackground
}
