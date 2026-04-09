import SwiftUI

struct Quote: Identifiable, Codable {
    let id: Int
    let text: String
    let author: String
    let category: QuoteCategory
}

enum QuoteCategory: String, Codable, CaseIterable, Identifiable {
    case courage
    case decision
    case soi
    case relations
    case travail
    case nature

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .courage: "Courage"
        case .decision: "Décision"
        case .soi: "Soi"
        case .relations: "Relations"
        case .travail: "Travail"
        case .nature: "Nature"
        }
    }

    var color: Color {
        switch self {
        case .courage: .quoteCourage
        case .decision: .quoteDecision
        case .soi: .quoteSoi
        case .relations: .quoteRelations
        case .travail: .quoteTravail
        case .nature: .quoteNature
        }
    }

    /// Catégories adaptées à l'humeur basse
    static func forLowMood() -> [QuoteCategory] {
        [.courage, .soi]
    }

    /// Catégories adaptées à l'humeur haute
    static func forHighMood() -> [QuoteCategory] {
        [.decision, .travail, .nature]
    }
}

// MARK: - Citations intégrées

let allQuotes: [Quote] = [
    // COURAGE (20)
    Quote(id: 1, text: "Le courage n'est pas l'absence de peur, mais la capacité de vaincre ce qui fait peur.", author: "Nelson Mandela", category: .courage),
    Quote(id: 2, text: "Ce n'est pas parce que les choses sont difficiles que nous n'osons pas, c'est parce que nous n'osons pas qu'elles sont difficiles.", author: "Sénèque", category: .courage),
    Quote(id: 3, text: "La vie rétrécit ou s'élargit à proportion de ton courage.", author: "Anaïs Nin", category: .courage),
    Quote(id: 4, text: "Il faut avoir le chaos en soi pour enfanter une étoile qui danse.", author: "Nietzsche", category: .courage),
    Quote(id: 5, text: "Vis comme si tu devais mourir demain. Apprends comme si tu devais vivre toujours.", author: "Gandhi", category: .courage),
    Quote(id: 6, text: "Le plus grand risque est de ne prendre aucun risque.", author: "Mark Zuckerberg", category: .courage),
    Quote(id: 7, text: "On ne découvre pas de nouvelle terre sans consentir à perdre de vue le rivage.", author: "André Gide", category: .courage),
    Quote(id: 8, text: "La seule façon de faire du bon travail est d'aimer ce que vous faites.", author: "Steve Jobs", category: .courage),
    Quote(id: 9, text: "Tout ce que tu as toujours voulu est de l'autre côté de la peur.", author: "George Addair", category: .courage),
    Quote(id: 10, text: "Ce qui ne me tue pas me rend plus fort.", author: "Nietzsche", category: .courage),
    Quote(id: 11, text: "Il n'y a qu'une façon d'échouer, c'est d'abandonner avant d'avoir réussi.", author: "Olivier Lockert", category: .courage),
    Quote(id: 12, text: "Aie le courage de suivre ton cœur et ton intuition. Ils savent déjà ce que tu veux devenir.", author: "Steve Jobs", category: .courage),
    Quote(id: 13, text: "Commence là où tu es. Utilise ce que tu as. Fais ce que tu peux.", author: "Arthur Ashe", category: .courage),
    Quote(id: 14, text: "Le succès n'est pas final, l'échec n'est pas fatal : c'est le courage de continuer qui compte.", author: "Winston Churchill", category: .courage),
    Quote(id: 15, text: "N'aie pas peur d'avancer lentement, aie peur de rester immobile.", author: "Proverbe chinois", category: .courage),
    Quote(id: 16, text: "La difficulté de réussir ne fait qu'ajouter à la nécessité d'entreprendre.", author: "Beaumarchais", category: .courage),
    Quote(id: 17, text: "On peut aussi bâtir quelque chose de beau avec les pierres qui entravent le chemin.", author: "Goethe", category: .courage),
    Quote(id: 18, text: "Le monde appartient à ceux qui osent.", author: "Proverbe français", category: .courage),

    // DÉCISION (18)
    Quote(id: 19, text: "Dans tout ce que tu fais, considère la fin.", author: "Solon", category: .decision),
    Quote(id: 20, text: "La vie est la somme de toutes tes décisions.", author: "Albert Camus", category: .decision),
    Quote(id: 21, text: "Ne pas choisir, c'est encore choisir.", author: "Jean-Paul Sartre", category: .decision),
    Quote(id: 22, text: "Quand on ne peut revenir en arrière, on ne doit se préoccuper que de la meilleure façon d'aller de l'avant.", author: "Paulo Coelho", category: .decision),
    Quote(id: 23, text: "Il faut savoir ce que l'on veut. Quand on le sait, il faut avoir le courage de le dire ; quand on le dit, il faut avoir le courage de le faire.", author: "Clemenceau", category: .decision),
    Quote(id: 24, text: "Nous sommes nos choix.", author: "Jean-Paul Sartre", category: .decision),
    Quote(id: 25, text: "La plus grande gloire n'est pas de ne jamais tomber, mais de se relever à chaque chute.", author: "Confucius", category: .decision),
    Quote(id: 26, text: "Chaque matin nous naissons de nouveau. Ce que nous faisons aujourd'hui est ce qui compte le plus.", author: "Bouddha", category: .decision),
    Quote(id: 27, text: "L'homme n'est rien d'autre que ce qu'il se fait.", author: "Jean-Paul Sartre", category: .decision),
    Quote(id: 28, text: "Il est bien des choses qui ne paraissent impossibles que tant qu'on ne les a pas tentées.", author: "André Gide", category: .decision),
    Quote(id: 29, text: "L'avenir appartient à ceux qui croient en la beauté de leurs rêves.", author: "Eleanor Roosevelt", category: .decision),
    Quote(id: 30, text: "Sois le changement que tu veux voir dans le monde.", author: "Gandhi", category: .decision),
    Quote(id: 31, text: "Le meilleur moment pour planter un arbre était il y a vingt ans. Le deuxième meilleur moment est maintenant.", author: "Proverbe chinois", category: .decision),
    Quote(id: 32, text: "L'important n'est pas ce qu'on fait de nous, mais ce que nous faisons nous-mêmes de ce qu'on a fait de nous.", author: "Jean-Paul Sartre", category: .decision),
    Quote(id: 33, text: "Choisir, c'est renoncer.", author: "André Gide", category: .decision),
    Quote(id: 34, text: "Le plus difficile dans la vie, c'est de savoir quel pont traverser et quel pont brûler.", author: "Bertrand Russell", category: .decision),

    // SOI (18)
    Quote(id: 35, text: "Connais-toi toi-même.", author: "Socrate", category: .soi),
    Quote(id: 36, text: "Deviens ce que tu es.", author: "Nietzsche", category: .soi),
    Quote(id: 37, text: "Il n'y a qu'un héroïsme au monde : c'est de voir le monde tel qu'il est, et de l'aimer.", author: "Romain Rolland", category: .soi),
    Quote(id: 38, text: "On ne voit bien qu'avec le cœur. L'essentiel est invisible pour les yeux.", author: "Saint-Exupéry", category: .soi),
    Quote(id: 39, text: "Être soi-même dans un monde qui essaie constamment de faire de vous quelqu'un d'autre est le plus grand accomplissement.", author: "Ralph Waldo Emerson", category: .soi),
    Quote(id: 40, text: "Le bonheur n'est pas quelque chose de prêt à l'emploi. Il vient de vos propres actions.", author: "Dalaï Lama", category: .soi),
    Quote(id: 41, text: "On ne peut rien enseigner à un homme, on peut seulement l'aider à trouver la réponse en lui-même.", author: "Galilée", category: .soi),
    Quote(id: 42, text: "Chacun de nous porte en lui un monde qu'il ne connaît pas.", author: "Alfred de Musset", category: .soi),
    Quote(id: 43, text: "Le vrai voyage de découverte ne consiste pas à chercher de nouveaux paysages, mais à avoir de nouveaux yeux.", author: "Marcel Proust", category: .soi),
    Quote(id: 44, text: "Il faut toujours viser la lune, car même en cas d'échec, on atterrit dans les étoiles.", author: "Oscar Wilde", category: .soi),
    Quote(id: 45, text: "La simplicité est la sophistication suprême.", author: "Léonard de Vinci", category: .soi),
    Quote(id: 46, text: "La seule personne que tu es destiné à devenir est la personne que tu décides d'être.", author: "Ralph Waldo Emerson", category: .soi),
    Quote(id: 47, text: "Si vous êtes toujours en train d'essayer d'être normal, vous ne saurez jamais à quel point vous pouvez être extraordinaire.", author: "Maya Angelou", category: .soi),
    Quote(id: 48, text: "Ce que nous pensons, nous le devenons.", author: "Bouddha", category: .soi),
    Quote(id: 49, text: "Rien ne vous emprisonne excepté vos pensées. Rien ne vous limite excepté vos peurs.", author: "Marianne Williamson", category: .soi),
    Quote(id: 50, text: "Je pense, donc je suis.", author: "Descartes", category: .soi),

    // RELATIONS (18)
    Quote(id: 51, text: "L'enfer, c'est les autres.", author: "Jean-Paul Sartre", category: .relations),
    Quote(id: 52, text: "Un ami, c'est quelqu'un qui vous connaît bien et qui vous aime quand même.", author: "Hervé Lauwick", category: .relations),
    Quote(id: 53, text: "La mesure de l'amour, c'est d'aimer sans mesure.", author: "Saint Augustin", category: .relations),
    Quote(id: 54, text: "Les gens oublieront ce que vous avez dit, ils oublieront ce que vous avez fait, mais ils n'oublieront jamais ce que vous leur avez fait ressentir.", author: "Maya Angelou", category: .relations),
    Quote(id: 55, text: "Aimer, c'est savoir dire je t'aime sans parler.", author: "Victor Hugo", category: .relations),
    Quote(id: 56, text: "Seul on va plus vite, ensemble on va plus loin.", author: "Proverbe africain", category: .relations),
    Quote(id: 57, text: "Le plus beau cadeau que l'on puisse faire à quelqu'un, c'est notre temps.", author: "Anonyme", category: .relations),
    Quote(id: 58, text: "On reconnaît le bonheur au bruit qu'il fait quand il s'en va.", author: "Jacques Prévert", category: .relations),
    Quote(id: 59, text: "Aimer, ce n'est pas se regarder l'un l'autre, c'est regarder ensemble dans la même direction.", author: "Saint-Exupéry", category: .relations),
    Quote(id: 60, text: "La solitude est belle quand on a quelqu'un à qui dire que la solitude est belle.", author: "Gustavo Adolfo Bécquer", category: .relations),
    Quote(id: 61, text: "Les vrais amis sont ceux qui comprennent ton passé, croient en ton avenir et t'acceptent tel que tu es.", author: "Anonyme", category: .relations),
    Quote(id: 62, text: "La gentillesse est un langage que les sourds peuvent entendre et que les aveugles peuvent voir.", author: "Mark Twain", category: .relations),
    Quote(id: 63, text: "Être profondément aimé par quelqu'un te donne de la force, et aimer profondément quelqu'un te donne du courage.", author: "Lao Tseu", category: .relations),

    // TRAVAIL (16)
    Quote(id: 64, text: "Le génie, c'est un pour cent d'inspiration et quatre-vingt-dix-neuf pour cent de transpiration.", author: "Thomas Edison", category: .travail),
    Quote(id: 65, text: "La créativité, c'est l'intelligence qui s'amuse.", author: "Albert Einstein", category: .travail),
    Quote(id: 66, text: "Le travail éloigne de nous trois grands maux : l'ennui, le vice et le besoin.", author: "Voltaire", category: .travail),
    Quote(id: 67, text: "Ce n'est pas le vent qui décide de ta destination, c'est l'orientation que tu donnes à ta voile.", author: "Jim Rohn", category: .travail),
    Quote(id: 68, text: "La persévérance, c'est ce qui rend l'impossible possible, le possible probable et le probable réalisé.", author: "Robert Half", category: .travail),
    Quote(id: 69, text: "Le talent, c'est l'envie de faire quelque chose.", author: "Jacques Brel", category: .travail),
    Quote(id: 70, text: "L'imagination est plus importante que le savoir.", author: "Albert Einstein", category: .travail),
    Quote(id: 71, text: "Rien de grand ne s'est accompli dans le monde sans passion.", author: "Hegel", category: .travail),
    Quote(id: 72, text: "La meilleure façon de prédire l'avenir est de le créer.", author: "Peter Drucker", category: .travail),
    Quote(id: 73, text: "N'attendez pas le moment parfait. Prenez le moment présent et rendez-le parfait.", author: "Anonyme", category: .travail),
    Quote(id: 74, text: "Le succès est la somme de petits efforts répétés jour après jour.", author: "Robert Collier", category: .travail),
    Quote(id: 75, text: "Votre temps est limité, ne le gâchez pas en menant une existence qui n'est pas la vôtre.", author: "Steve Jobs", category: .travail),
    Quote(id: 76, text: "L'échec est simplement l'opportunité de recommencer, cette fois de façon plus intelligente.", author: "Henry Ford", category: .travail),

    // NATURE (16)
    Quote(id: 77, text: "Dans chaque promenade dans la nature, on reçoit bien plus que ce que l'on cherche.", author: "John Muir", category: .nature),
    Quote(id: 78, text: "La terre ne nous appartient pas, nous appartenons à la terre.", author: "Chef Seattle", category: .nature),
    Quote(id: 79, text: "Regarde au fond de la nature, et alors tu comprendras mieux tout.", author: "Albert Einstein", category: .nature),
    Quote(id: 80, text: "La nature ne se presse pas, et pourtant tout est accompli.", author: "Lao Tseu", category: .nature),
    Quote(id: 81, text: "La simplicité est la clé de la brillance.", author: "Bruce Lee", category: .nature),
    Quote(id: 82, text: "Le monde est un livre et ceux qui ne voyagent pas n'en lisent qu'une page.", author: "Saint Augustin", category: .nature),
    Quote(id: 83, text: "Rien n'est art si cela ne vient pas de la nature.", author: "Antoni Gaudí", category: .nature),
    Quote(id: 84, text: "La nature fait les choses sans se presser, et pourtant tout est accompli.", author: "Lao Tseu", category: .nature),
    Quote(id: 85, text: "Chaque fleur est une âme à la nature éclose.", author: "Gérard de Nerval", category: .nature),
    Quote(id: 86, text: "La mer est tout. Elle couvre les sept dixièmes du globe terrestre.", author: "Jules Verne", category: .nature),
    Quote(id: 87, text: "Les arbres sont les poèmes que la terre écrit dans le ciel.", author: "Khalil Gibran", category: .nature),
    Quote(id: 88, text: "C'est dans la rosée des petites choses que le cœur trouve son matin et se rafraîchit.", author: "Khalil Gibran", category: .nature),
    Quote(id: 89, text: "La montagne reste immobile, elle laisse le vent passer.", author: "Proverbe japonais", category: .nature),
    Quote(id: 90, text: "Adopte le rythme de la nature. Son secret est la patience.", author: "Ralph Waldo Emerson", category: .nature),
]
