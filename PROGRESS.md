# Patchi — Suivi d'avancement

> Dernière mise à jour : 1er avril 2026

---

## Résumé du projet

App iOS native SwiftUI — journal de vie intelligent en français natif.
Combine journaling émotionnel, accountability personnel, et journal de décisions avec rappels J+30/J+90.
Mascotte Patchi (petite patate orange chibi). Freemium ~35€/an.

**Stack :** SwiftUI · SwiftData · iOS 17+ · MVVM · XcodeGen · StoreKit 2 · Pas d'IA
**Simulateur :** iPhone 17, iOS 26.2

---

## Tâches complétées

### TM #1 — Setup XcodeGen + structure projet ✅
- `project.yml` XcodeGen configuré (iOS 17+)
- `PatchiApp.swift` avec ModelContainer SwiftData (5 models)
- `AppState` (@Observable) + `RootView` + `MainTabView` (5 tabs)
- 5 @Model : User, CheckIn, AccountabilityEntry, Decision, FutureLetter
- 6 Enums : Emotion (20), Activity (20), HeatmapColor, Verdict, DecisionStatus, AppTheme
- 3 Extensions : Color+Mood (7 couleurs vives), Date+Helpers, View+Transitions
- Info.plist avec permissions (micro, caméra, photo, Face ID, speech)
- Assets.xcassets avec AccentColor orange Patchi
- .gitignore configuré pour Xcode + Swift
- **Le projet compile** ✅

### TM #7 — PatchiView et système d'expressions ✅
- `PatchiExpression` : 21 expressions (happy → determined)
  - Mapping automatique depuis moodScore (1-5)
  - Mapping depuis contexte (onboarding, reformulation, verdict, etc.)
  - Couleurs d'accent par expression
  - SF Symbols de fallback
- `PatchiView` : composant réutilisable
  - Animation de respiration (oscillation verticale 1.8s)
  - 4 tailles : small (44pt), medium (80pt), large (140pt), hero (200pt)
  - Placeholder vectoriel SwiftUI (corps patate orange, yeux adaptatifs, joues rosées, bouche selon expression)
  - Prêt pour les vrais assets → nommer `patchi_happy`, `patchi_sad`, etc. dans xcassets
- `PatchiSpeechBubble` : bulle de dialogue
  - Animation texte mot par mot (35ms/caractère)
  - 3 styles : standard (blanc), emotional (orange léger), subtle (gris)
  - Composant combo `PatchiWithBubble`
- **Le projet compile** ✅

### Tâches faites en avance (incluses dans TM #1)
- TM #2 — Models SwiftData User + CheckIn ✅
- TM #3 — Models AccountabilityEntry, Decision, FutureLetter ✅
- TM #4 — Enums et structs ✅
- TM #5 — Extensions ✅
- TM #6 — AppState, AppRouter, TabView ✅

---

## Prochaines tâches

| # | Tâche | Priorité | Dépendances | Statut |
|---|-------|----------|-------------|--------|
| 8 | ReformulationService | High | Aucune | À faire |
| 9 | NotificationService | High | Aucune | À faire |
| 10 | MoodSliderView | High | #5, #7 ✅ | Prêt |
| 11 | ActivityGridView + EmotionGridView | High | #4 ✅ | Prêt |
| 12 | CheckInView complet | High | #2, #8, #10, #11 | Bloqué par #8 |
| 13 | SpeechService (voix) | Medium | Aucune | À faire |
| 14 | HeatmapGridView + HeatmapService | High | #3, #4, #5 ✅ | Prêt |

**Recommandé :** TM #8 (ReformulationService) ou TM #9 (NotificationService) — les deux sont indépendants et débloquent beaucoup de tâches.

---

## Structure du projet

```
Patchi/
├── App/
│   ├── PatchiApp.swift          ← Point d'entrée, ModelContainer
│   ├── AppState.swift           ← État global @Observable
│   ├── RootView.swift           ← Onboarding ou MainTabView
│   └── MainTabView.swift        ← 5 tabs + bouton central
├── Models/
│   ├── User.swift
│   ├── CheckIn.swift
│   ├── AccountabilityEntry.swift
│   ├── Decision.swift
│   ├── FutureLetter.swift
│   └── Enums/
│       ├── Emotion.swift        ← 20 émotions avec icônes
│       ├── Activity.swift       ← 20 activités avec icônes
│       ├── HeatmapColor.swift   ← rouge/orange/vertClair/vertFoncé
│       ├── Verdict.swift        ← raison/partiellement/tort + DecisionStatus
│       └── AppTheme.swift       ← default/dark/ocean/forest/sunset
├── Features/
│   ├── Onboarding/OnboardingView.swift     (placeholder)
│   ├── Home/HomeView.swift                 (placeholder)
│   ├── Quotes/QuotesFeedView.swift         (placeholder)
│   ├── Stats/StatsView.swift               (placeholder)
│   └── Journal/JournalView.swift           (placeholder)
├── Components/
│   └── Patchi/
│       ├── PatchiExpression.swift   ← 21 expressions + contextes
│       ├── PatchiView.swift         ← Composant avec animation respiration
│       └── PatchiSpeechBubble.swift ← Bulle mot par mot + PatchiWithBubble
├── Extensions/
│   ├── Color+Mood.swift         ← 7 couleurs vives d'humeur
│   ├── Date+Helpers.swift       ← Helpers date en français
│   └── View+Transitions.swift   ← Animations Patchi 400-600ms
└── Resources/
    ├── Info.plist
    ├── Assets.xcassets/
    └── Fonts/                   (Crimson Pro à ajouter)
```

---

## Fichiers de référence

| Fichier | Description |
|---------|-------------|
| `Application iOS Journal de Décisions.md` | Spec complète du projet (source de vérité produit) |
| `.taskmaster/docs/prd.md` | PRD technique pour TaskMaster (57/57 EXCELLENT) |
| `.taskmaster/docs/swift-docs.md` | Doc à jour des 10 frameworks utilisés |
| `.taskmaster/tasks/tasks.json` | 40 tâches avec dépendances et priorités |
| `CLAUDE.md` | Guide projet pour Claude Code |
| `project.yml` | Config XcodeGen |

---

## Assets Patchi — Comment intégrer les vrais visuels

1. Exporter les images Midjourney en PNG transparent
2. Les nommer selon le pattern : `patchi_happy.png`, `patchi_sad.png`, `patchi_neutral.png`, etc.
3. Les glisser dans `Patchi/Resources/Assets.xcassets/` (créer un Image Set par expression)
4. Le `PatchiView` détectera automatiquement les assets et arrêtera d'utiliser le placeholder vectoriel

Expressions à couvrir : happy, excited, proud, grateful, celebrating, calm, neutral, thinking, curious, waving, sleeping, sad, tired, worried, stressed, angry, surprised, nostalgic, comforting, determined

---

## Points d'attention (analyse Rodin)

- **Dispersion :** 3 dimensions (journaling + accountability + décisions) = 3 postures psychologiques. Risque que l'app ne sache pas ce qu'elle est.
- **Reformulation sans IA :** Templates statiques → au bout de 2 semaines l'utilisateur peut sentir que Patchi ne le comprend pas vraiment. Prévoir beaucoup de variantes.
- **Vrai concurrent :** Notes d'Apple et le carnet papier, pas Reflectly.
- **Killer feature sous-estimée :** Le rituel du dimanche (RDV hebdo structuré > journal quotidien).
- **Rétention :** Le seul problème qui compte. 85-90% de churn avant 2 semaines en journaling.
- **Question clé :** "Quelle est la seule chose que Patchi fait mieux que tout le monde ?"
