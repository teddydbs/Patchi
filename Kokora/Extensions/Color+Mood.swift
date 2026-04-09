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

    static let kokoraOrange = Color(red: 1.0, green: 0.6, blue: 0.2)

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

    /// Lien bleu — boutons textuels type "Mot de passe oublié ?"
    static let dsLink = Color(red: 0.26, green: 0.52, blue: 0.96)

    // MARK: Legacy aliases

    static let cardBackground = dsCard
    static let pageBackground = dsBackground

    // MARK: Motion Design Tokens

    static let mdBg = Color.white
    static let mdBgSubtle = Color(red: 0.969, green: 0.969, blue: 0.961)
    static let mdGreen = Color(red: 0.243, green: 0.788, blue: 0.384)
    static let mdGreenBg = Color(red: 0.91, green: 0.976, blue: 0.929)
    static let mdOrange = Color(red: 1.0, green: 0.549, blue: 0.259)
    static let mdOrangeBg = Color(red: 1.0, green: 0.949, blue: 0.91)
    static let mdPurple = Color(red: 0.486, green: 0.228, blue: 0.929)
    static let mdPurpleBg = Color(red: 0.941, green: 0.925, blue: 0.988)
    static let mdYellow = Color(red: 0.984, green: 0.749, blue: 0.141)
    static let mdYellowBg = Color(red: 1.0, green: 0.969, blue: 0.886)
    static let mdTextBlack = Color(red: 0.102, green: 0.102, blue: 0.102)
    static let mdTextGray = Color(red: 0.533, green: 0.533, blue: 0.533)
    static let mdTextLight = Color(red: 0.733, green: 0.733, blue: 0.733)
    static let mdBorder = Color(red: 0.941, green: 0.941, blue: 0.933)

    static func moodVivid(_ score: Int) -> Color {
        switch score {
        case 5: return Color(red: 0.984, green: 0.749, blue: 0.141)
        case 4: return Color(red: 0.29, green: 0.871, blue: 0.502)
        case 3: return Color(red: 0.91, green: 0.878, blue: 0.847)
        case 2: return Color(red: 0.722, green: 0.604, blue: 0.91)
        case 1: return Color(red: 0.506, green: 0.549, blue: 0.973)
        default: return Color(red: 0.953, green: 0.953, blue: 0.945)
        }
    }
}
