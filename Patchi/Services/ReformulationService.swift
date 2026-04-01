import Foundation

/// Service 100% local qui transforme les mots de l'utilisateur en "vérités" Patchi.
/// Analyse tokenisée du texte, matching par mots-clés, retourne la phrase la plus pertinente.
final class ReformulationService {
    static let shared = ReformulationService()

    private init() {}

    // MARK: - Public API

    /// Reformule le texte de l'utilisateur en une phrase Patchi
    func reformulate(_ text: String) -> String {
        let tokens = tokenize(text)
        let matchedThemes = findThemes(in: tokens)

        if let bestTheme = matchedThemes.first {
            return bestTheme.phrases.randomElement() ?? genericPhrases.randomElement()!
        }

        return genericPhrases.randomElement()!
    }

    /// Détecte les thèmes récurrents sur plusieurs textes (pour les questions adaptatives)
    func detectRecurringThemes(in texts: [String]) -> [Theme] {
        var themeCounts: [Theme: Int] = [:]

        for text in texts {
            let tokens = tokenize(text)
            let themes = findThemes(in: tokens)
            for theme in themes {
                themeCounts[theme, default: 0] += 1
            }
        }

        return themeCounts
            .sorted { $0.value > $1.value }
            .map(\.key)
    }

    /// Retourne une phrase d'intention basée sur un thème récurrent
    func intentionPhrase(for theme: Theme) -> String {
        theme.intentionPhrase
    }

    // MARK: - Tokenization

    private func tokenize(_ text: String) -> [String] {
        text.lowercased()
            .folding(options: .diacriticInsensitive, locale: Locale(identifier: "fr"))
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 2 }
    }

    private func findThemes(in tokens: [String]) -> [Theme] {
        var matched: [(theme: Theme, score: Int)] = []

        for theme in Theme.allCases {
            let score = theme.keywords.reduce(0) { total, keyword in
                total + (tokens.contains(keyword) ? 1 : 0)
            }
            if score > 0 {
                matched.append((theme, score))
            }
        }

        return matched
            .sorted { $0.score > $1.score }
            .map(\.theme)
    }

    // MARK: - Generic Phrases

    private let genericPhrases: [String] = [
        "Tu prends le temps de regarder en toi. C'est déjà beaucoup.",
        "Ce que tu ressens compte.",
        "Parfois, poser les mots suffit.",
        "Tu es plus honnête avec toi-même que tu ne le crois.",
        "C'est noté. On y reviendra.",
        "Le fait d'y penser, c'est déjà un pas.",
        "Tu fais attention à toi. Continue.",
        "Quelque chose travaille en toi. Laisse-le faire.",
        "Tu te poses les bonnes questions.",
        "C'est une journée de plus où tu as été présent.",
    ]
}

// MARK: - Theme

enum Theme: String, CaseIterable, Hashable {
    case corps
    case travail
    case relations
    case famille
    case amour
    case argent
    case sante
    case projets
    case repos
    case creativite
    case nature
    case apprentissage
    case confiance
    case solitude
    case stress
    case gratitude
    case temps
    case alimentation
    case spiritualite
    case courage

    var keywords: [String] {
        switch self {
        case .corps:
            ["sport", "corps", "gym", "musculation", "courir", "marcher", "yoga", "exercice",
             "bouger", "physique", "entrainement", "poids", "muscles", "etirer", "nager"]
        case .travail:
            ["travail", "boulot", "job", "bureau", "boss", "collegue", "reunion", "projet",
             "deadline", "salaire", "promotion", "carriere", "demission", "burn", "productif"]
        case .relations:
            ["ami", "amis", "amitie", "gens", "social", "sortir", "relation", "copain",
             "copine", "entourage", "confiance", "dispute", "parler", "ecouter", "rencontrer"]
        case .famille:
            ["famille", "parents", "mere", "pere", "frere", "soeur", "enfant", "enfants",
             "maman", "papa", "maison", "fille", "fils", "grand", "cousin"]
        case .amour:
            ["amour", "couple", "aimer", "amoureuse", "amoureux", "partenaire", "mariage",
             "rupture", "coeur", "sentiments", "intimite", "tendresse", "jalousie", "manque"]
        case .argent:
            ["argent", "money", "finances", "economiser", "depenser", "budget", "dette",
             "investir", "epargne", "salaire", "cher", "prix", "acheter", "payer", "banque"]
        case .sante:
            ["sante", "malade", "medecin", "docteur", "hopital", "douleur", "mal",
             "sommeil", "dormir", "fatigue", "energie", "migraine", "anxiete", "depression"]
        case .projets:
            ["projet", "objectif", "reve", "ambition", "plan", "avenir", "futur",
             "entreprise", "lancer", "creer", "construire", "idee", "motivation", "reussir"]
        case .repos:
            ["repos", "reposer", "detente", "relax", "pause", "vacances", "dormir",
             "sieste", "calme", "tranquille", "rien", "souffler", "weekend", "recuperer"]
        case .creativite:
            ["creer", "ecrire", "dessiner", "peindre", "musique", "jouer", "instrument",
             "art", "photo", "video", "chanter", "danser", "imaginer", "inventer", "composer"]
        case .nature:
            ["nature", "dehors", "foret", "mer", "montagne", "jardin", "plante",
             "arbre", "soleil", "ciel", "air", "promenade", "randonnee", "plage", "riviere"]
        case .apprentissage:
            ["apprendre", "lire", "livre", "etudier", "cours", "formation", "comprendre",
             "savoir", "connaissance", "ecole", "universite", "diplome", "competence", "progresser"]
        case .confiance:
            ["confiance", "doute", "peur", "oser", "capable", "croire", "courage",
             "risque", "decision", "choix", "hesiter", "fierté", "assurance", "legitimite"]
        case .solitude:
            ["seul", "solitude", "isole", "personne", "vide", "manque", "absence",
             "abandonner", "invisible", "incompris", "ennui", "melancolie"]
        case .stress:
            ["stress", "angoisse", "anxiete", "pression", "surcharge", "panique",
             "nerveux", "tendu", "oppresse", "submerge", "craquer", "limite", "epuise"]
        case .gratitude:
            ["merci", "chance", "reconnaissant", "gratitude", "apprecier", "content",
             "heureux", "joie", "beau", "magnifique", "genial", "super", "formidable"]
        case .temps:
            ["temps", "vite", "lent", "attendre", "patience", "urgent", "retard",
             "passer", "perdre", "profiter", "moment", "instant", "maintenant", "hier"]
        case .alimentation:
            ["manger", "nourriture", "cuisine", "repas", "regime", "sain", "gras",
             "sucre", "legume", "fruit", "boire", "eau", "alcool", "cafe", "gourmand"]
        case .spiritualite:
            ["mediter", "meditation", "prier", "priere", "ame", "esprit", "sens",
             "spirituel", "univers", "gratitude", "paix", "harmonie", "conscience", "respirer"]
        case .courage:
            ["courage", "brave", "affronter", "depasser", "surmonter", "resilience",
             "fort", "tenir", "lutter", "combattre", "abandonner", "perseverer", "force"]
        }
    }

    var phrases: [String] {
        switch self {
        case .corps:
            [
                "Tu veux prendre soin de toi.",
                "Ton corps te parle. Tu l'écoutes.",
                "Bouger, c'est ta façon de te retrouver.",
                "Tu sais que ton corps a besoin de toi.",
                "Le mouvement te fait du bien. Tu le sens.",
            ]
        case .travail:
            [
                "Le travail te pèse.",
                "Tu portes beaucoup en ce moment.",
                "Ta vie pro prend de la place dans ta tête.",
                "Tu cherches un équilibre avec ton travail.",
                "Ce qui se passe au boulot te touche plus que tu ne le montres.",
            ]
        case .relations:
            [
                "Les gens autour de toi comptent.",
                "Tu as besoin de connexion.",
                "Tes relations te nourrissent — ou te pèsent.",
                "Tu penses à ceux qui comptent pour toi.",
                "Le lien avec les autres, c'est ce qui te porte.",
            ]
        case .famille:
            [
                "Ta famille compte beaucoup pour toi.",
                "Il y a quelque chose avec ta famille en ce moment.",
                "Les liens familiaux te travaillent.",
                "Tu portes ta famille avec toi, même quand elle est loin.",
                "Ce qui se passe chez toi résonne en toi.",
            ]
        case .amour:
            [
                "L'amour prend de la place.",
                "Tu penses à quelqu'un.",
                "Ton cœur est occupé en ce moment.",
                "L'amour te fait grandir — même quand ça fait mal.",
                "Ce que tu ressens est réel. Ne le minimise pas.",
            ]
        case .argent:
            [
                "L'argent te préoccupe.",
                "La question financière pèse.",
                "Tu veux te sentir en sécurité financièrement.",
                "L'argent, c'est aussi une question de liberté.",
                "Tu gères. Même si ça ne semble pas toujours évident.",
            ]
        case .sante:
            [
                "Ta santé te préoccupe.",
                "Prendre soin de ta santé, c'est te prioriser.",
                "Tu écoutes ton corps. C'est bien.",
                "La santé, c'est le fondement de tout le reste.",
                "Tu fais attention à toi. C'est important.",
            ]
        case .projets:
            [
                "Tu as quelque chose en toi qui veut sortir.",
                "Ton ambition travaille.",
                "Tu construis quelque chose. Continue.",
                "Ce projet te tient à cœur. Ça se sent.",
                "Tu as une vision. Fais-lui confiance.",
            ]
        case .repos:
            [
                "Tu as besoin de souffler.",
                "Le repos n'est pas de la paresse.",
                "Ton corps et ton esprit te demandent une pause.",
                "Parfois, ne rien faire est la chose la plus productive.",
                "Accorde-toi ce que tu mérites : du temps.",
            ]
        case .creativite:
            [
                "Tu as besoin de créer.",
                "L'art te fait du bien. Donne-lui de la place.",
                "Ton côté créatif veut s'exprimer.",
                "Créer, c'est ta façon de respirer.",
                "Quand tu crées, tu es toi-même.",
            ]
        case .nature:
            [
                "La nature t'appelle.",
                "Tu as besoin d'air.",
                "Dehors, tu te retrouves.",
                "Le contact avec la nature te recentre.",
                "Prendre l'air, c'est prendre soin de toi.",
            ]
        case .apprentissage:
            [
                "Tu veux grandir.",
                "Apprendre te motive. C'est un moteur.",
                "Tu investis en toi. C'est le meilleur placement.",
                "La curiosité te pousse en avant.",
                "Tu construis, une connaissance à la fois.",
            ]
        case .confiance:
            [
                "Tu doutes, mais tu avances quand même.",
                "La confiance se construit pas à pas.",
                "Le doute n'est pas un ennemi. C'est un signal.",
                "Tu es plus capable que tu ne le penses.",
                "Oser, c'est déjà avoir du courage.",
            ]
        case .solitude:
            [
                "Tu te sens seul. C'est humain.",
                "La solitude peut peser. Ne la porte pas en silence.",
                "Être seul ne veut pas dire être abandonné.",
                "Tu mérites d'être entouré.",
                "Ce sentiment passera. Mais il est réel maintenant.",
            ]
        case .stress:
            [
                "Tu portes trop en ce moment.",
                "Le stress te mange. Pose quelque chose.",
                "Tu n'es pas obligé de tout gérer en même temps.",
                "Respire. Un problème à la fois.",
                "La pression que tu ressens est réelle. Sois doux avec toi.",
            ]
        case .gratitude:
            [
                "Tu vois le beau. C'est une force.",
                "La gratitude te garde ancré.",
                "Tu sais apprécier ce que tu as. C'est rare.",
                "Ces moments de joie méritent d'être notés.",
                "Tu es dans un bon moment. Savoure-le.",
            ]
        case .temps:
            [
                "Le temps te file entre les doigts.",
                "Tu veux ralentir. C'est légitime.",
                "Le temps est ta ressource la plus précieuse.",
                "Tu as le droit de prendre ton temps.",
                "Profiter du présent, c'est un choix actif.",
            ]
        case .alimentation:
            [
                "Ce que tu manges dit quelque chose de toi.",
                "Tu fais attention à ton alimentation. C'est un acte de soin.",
                "Manger bien, c'est se respecter.",
                "Ton rapport à la nourriture évolue. C'est ok.",
                "Nourrir ton corps, c'est nourrir ton esprit.",
            ]
        case .spiritualite:
            [
                "Tu cherches un sens plus profond.",
                "La paix intérieure te manque.",
                "Tu aspires à quelque chose de plus grand.",
                "Méditer, c'est revenir à toi.",
                "Tu es en quête. C'est beau.",
            ]
        case .courage:
            [
                "Tu es plus fort que tu ne le crois.",
                "Le courage, c'est avancer malgré la peur.",
                "Tu tiens bon. C'est déjà énorme.",
                "Chaque pas compte, même les petits.",
                "Tu n'abandonnes pas. C'est ta force.",
            ]
        }
    }

    var intentionPhrase: String {
        switch self {
        case .corps: "Tu sembles penser souvent à ton corps. Tu veux qu'on suive ça ?"
        case .travail: "Le travail revient souvent. Tu veux en faire un suivi ?"
        case .relations: "Tes relations comptent pour toi. On les suit ensemble ?"
        case .famille: "Ta famille te préoccupe. Tu veux qu'on en garde une trace ?"
        case .amour: "L'amour prend de la place. Tu veux qu'on suive ça ?"
        case .argent: "L'argent revient dans tes pensées. Tu veux qu'on y prête attention ?"
        case .sante: "Ta santé te préoccupe. Tu veux qu'on la suive ?"
        case .projets: "Tu as des projets en tête. Tu veux qu'on les suive ?"
        case .repos: "Tu as besoin de repos. Tu veux qu'on en fasse une priorité ?"
        case .creativite: "La créativité t'attire. Tu veux qu'on suive ça ?"
        case .nature: "La nature te manque. Tu veux en faire un objectif ?"
        case .apprentissage: "Tu veux apprendre. Tu veux qu'on suive ta progression ?"
        case .confiance: "La confiance en toi revient souvent. Tu veux qu'on travaille dessus ?"
        case .solitude: "Tu te sens parfois seul. Tu veux qu'on en garde une trace ?"
        case .stress: "Le stress revient souvent. Tu veux qu'on le suive ?"
        case .gratitude: "Tu apprécies les bons moments. Tu veux qu'on les note ?"
        case .temps: "Le temps te préoccupe. Tu veux qu'on y prête attention ?"
        case .alimentation: "L'alimentation est importante pour toi. Tu veux qu'on suive ça ?"
        case .spiritualite: "Tu cherches un sens. Tu veux qu'on suive cette quête ?"
        case .courage: "Tu fais preuve de courage. Tu veux qu'on le reconnaisse ?"
        }
    }
}
