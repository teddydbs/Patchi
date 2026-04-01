# PRD: Patchi — Journal d'intégrité personnelle

**Author:** Teddy
**Date:** 2026-04-01
**Status:** Approved
**Version:** 1.0
**Taskmaster Optimized:** Yes

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Problem Statement](#problem-statement)
3. [Goals & Success Metrics](#goals--success-metrics)
4. [User Stories](#user-stories)
5. [Functional Requirements](#functional-requirements)
6. [Non-Functional Requirements](#non-functional-requirements)
7. [Technical Considerations](#technical-considerations)
8. [Implementation Roadmap](#implementation-roadmap)
9. [Out of Scope](#out-of-scope)
10. [Open Questions & Risks](#open-questions--risks)
11. [Validation Checkpoints](#validation-checkpoints)
12. [Appendix: Task Breakdown Hints](#appendix-task-breakdown-hints)

---

## Executive Summary

Patchi est un journal de vie intelligent pour iPhone, en français natif, qui combine journaling émotionnel quotidien, accountability personnel, et journal de décisions avec rappels à J+30 et J+90. L'app s'adresse aux francophones 25-40 ans en construction active de soi. Le marché francophone est actuellement non servi — Reflectly (13M utilisateurs) n'existe qu'en anglais. Patchi comble ce vide avec un produit supérieur pensé en français dès le premier mot, accompagné d'une mascotte attachante (Patchi, petite patate orange chibi).

Modèle freemium : toutes les saisies gratuites, premium ~35€/an pour analyses avancées, historique illimité, widgets et sync cloud.

---

## Problem Statement

### Current Situation
Les francophones qui veulent tenir un journal de vie ou tracker leurs décisions n'ont aucune app de qualité en français. Reflectly est exclusivement en anglais. Day One est un journal générique sans accountability ni suivi de décisions. Aucune app ne connecte les décisions passées avec le présent.

### User Impact
- **Who is affected:** Francophones 25-40 ans — entrepreneurs, étudiants ambitieux, personnes en période de changement (reconversion, séparation, nouveau job)
- **How they're affected:** Pas d'outil pour capturer et revisiter leurs décisions ; les apps de journaling existantes sont en anglais ou trop superficielles ; les streaks punissent au lieu de motiver
- **Severity:** High — les avis francophones de Reflectly convergent : l'absence de version française est le principal frein

### Business Impact
- **Opportunity:** Marché francophone non servi (France, Belgique, Suisse, Canada, Afrique francophone)
- **Competitive advantage:** Premier entrant en français avec une proposition de valeur unique (décisions + accountability + journaling)
- **Strategic importance:** Capturer le marché francophone avant que Reflectly ne se traduise

### Why Solve This Now?
- Reflectly n'a toujours pas de version française après des années de demandes
- Le self-improvement est un marché en croissance constante
- SwiftUI + SwiftData permettent un développement solo efficace
- Les visuels de la mascotte Patchi sont déjà créés et validés

---

## Goals & Success Metrics

### Goal 1: Acquisition — Téléchargements
- **Metric:** Nombre de téléchargements sur l'App Store
- **Baseline:** 0
- **Target:** 5 000 téléchargements dans les 3 premiers mois
- **Measurement:** App Store Connect analytics

### Goal 2: Rétention — Utilisateurs actifs J+7
- **Metric:** % d'utilisateurs qui reviennent au jour 7
- **Baseline:** 0
- **Target:** 40% de rétention J+7
- **Measurement:** Analytics in-app (compteur de check-ins)

### Goal 3: Conversion premium
- **Metric:** % d'utilisateurs gratuits qui passent premium
- **Baseline:** 0
- **Target:** 5% de conversion après J+30
- **Measurement:** StoreKit 2 analytics + App Store Connect

### Goal 4: Engagement quotidien
- **Metric:** Nombre moyen de check-ins par utilisateur actif par semaine
- **Baseline:** 0
- **Target:** 5 check-ins/semaine (usage quasi-quotidien)
- **Measurement:** SwiftData query sur les entrées

---

## User Stories

### Story 1: Mood Check-in quotidien
**As a** utilisateur francophone,
**I want to** enregistrer mon humeur, mes activités et mes émotions chaque jour,
**So that I can** suivre mon état émotionnel dans le temps et comprendre mes patterns.

**Acceptance Criteria:**
- [ ] Slider d'humeur de 1 à 5 avec visage Patchi animé
- [ ] Couleur de fond change en temps réel selon le score
- [ ] Grille de 20 activités sélectionnables (jusqu'à 10)
- [ ] Grille de 20 émotions sélectionnables (jusqu'à 10)
- [ ] Titre optionnel (une ligne)
- [ ] Note libre texte illimité ou enregistrement vocal
- [ ] Photo optionnelle (galerie ou caméra)
- [ ] Reformulation Patchi après validation (3 secondes puis disparaît)
- [ ] Plusieurs check-ins par jour possibles

**Dependencies:** Models SwiftData, PatchiView, Color+Mood, ReformulationService

---

### Story 2: Journal de décisions
**As a** utilisateur qui prend des décisions importantes,
**I want to** enregistrer mes décisions avec contexte et prédiction, et les revisiter à J+30 et J+90,
**So that I can** apprendre de mes décisions passées et voir si j'avais raison.

**Acceptance Criteria:**
- [ ] Formulaire : titre, contexte, prédiction, décision prise, importance 1-5
- [ ] Cards "en attente de verdict" visibles dans le journal
- [ ] Notification contextuelle à J+30 avec titre de la décision
- [ ] Notification contextuelle à J+90
- [ ] Écran verdict : décision originale + prédiction + champ verdict (raison/partiellement/tort)
- [ ] Moment de vérité avec Patchi présente

**Dependencies:** Models SwiftData, NotificationService, PatchiView

---

### Story 3: Accountability tracker
**As a** utilisateur qui veut se confronter honnêtement à lui-même,
**I want to** noter chaque soir ce que j'aurais voulu faire sans l'avoir fait,
**So that I can** voir ma progression sur une heatmap et identifier mes patterns de regrets.

**Acceptance Criteria:**
- [ ] Question du soir : "Qu'aurais-tu aimé faire aujourd'hui que tu n'as pas fait ?"
- [ ] Texte libre + raison + jugement valable/non valable
- [ ] Heatmap 90 jours (rouge → vert, intensité = importance 1-5)
- [ ] Bouton "Aujourd'hui tout allait bien" (skip positif)
- [ ] Rattrapage si jour raté (question le lendemain)

**Dependencies:** Models SwiftData, HeatmapService, HeatmapGridView

---

### Story 4: Onboarding avec Patchi
**As a** nouvel utilisateur,
**I want to** être accueilli par Patchi et faire ma première entrée immédiatement,
**So that I can** voir la valeur de l'app avant toute inscription.

**Acceptance Criteria:**
- [ ] 8 étapes : Patchi apparaît → prénom → première question → reformulation → premier carré heatmap → rappels → offre essai → création compte
- [ ] Valeur immédiate avant inscription
- [ ] Maximum 3 minutes du début à la fin
- [ ] Essai 7 jours sans carte bancaire
- [ ] Sign in with Apple disponible

**Dependencies:** PatchiView, OnboardingViewModel, StoreKitService

---

### Story 5: Lettre au futur moi
**As a** utilisateur introspectif,
**I want to** écrire une lettre à moi-même qui sera livrée dans 6 mois,
**So that I can** me reconnecter avec qui j'étais et mesurer mon évolution.

**Acceptance Criteria:**
- [ ] Invitation mensuelle de Patchi
- [ ] Lettre scellée après envoi (non modifiable)
- [ ] Notification spéciale 6 mois jour pour jour
- [ ] Animation d'ouverture de lettre
- [ ] Possibilité de répondre (la réponse devient une nouvelle lettre pour dans 6 mois)

**Dependencies:** Models SwiftData, NotificationService, PatchiView

---

### Story 6: Statistiques et insights
**As a** utilisateur régulier,
**I want to** voir des graphiques de mon humeur et des corrélations avec mes activités,
**So that I can** comprendre ce qui me fait du bien et ce qui me tire vers le bas.

**Acceptance Criteria:**
- [ ] Heatmap 90 jours d'accountability
- [ ] Courbe d'humeur hebdomadaire et mensuelle
- [ ] Corrélations simples activités ↔ humeur (gratuit)
- [ ] Corrélations avancées (premium)
- [ ] Countdown vers prochains insights (J+3, J+7, J+30)
- [ ] Stats de décisions (premium)

**Dependencies:** StatsViewModel, HeatmapService, InsightService, Charts framework

---

### Story 7: Rituel du dimanche
**As a** utilisateur qui veut faire le point chaque semaine,
**I want to** être guidé par Patchi dans un bilan hebdomadaire,
**So that I can** prendre du recul sur ma semaine et identifier les moments clés.

**Acceptance Criteria:**
- [ ] Session guidée 5-7 minutes chaque dimanche soir
- [ ] Questions contextuelles basées sur les entrées de la semaine
- [ ] Patchi guide le bilan
- [ ] Notification dimanche 19h00

**Dependencies:** InsightService, PatchiView, NotificationService

---

### Story 8: Citations et inspiration
**As a** utilisateur qui cherche de la motivation,
**I want to** parcourir un feed de citations adaptées à mon humeur,
**So that I can** trouver de l'inspiration au bon moment.

**Acceptance Criteria:**
- [ ] Feed swipeable plein écran avec grande typo italique
- [ ] Fond coloré selon catégorie (courage, décision, soi, relations, travail, nature)
- [ ] Citations adaptées à l'humeur (sans IA)
- [ ] Favoris + partage
- [ ] Citations personnalisées basées sur l'historique (premium)

**Dependencies:** QuotesFeedView, données de citations en local

---

### Story 9: Notifications configurables
**As a** utilisateur qui veut des rappels personnalisés,
**I want to** configurer quand et combien de fois je reçois des notifications,
**So that I can** maintenir mon habitude sans être envahi.

**Acceptance Criteria:**
- [ ] 5 types : soir, décision, J+30, lettre, dimanche
- [ ] Pool de 20 formulations différentes pour les notifications du soir
- [ ] Notifications mentionnent le contenu réel (titre de décision, nombre de jours)
- [ ] Double slider heure début/fin + nombre de rappels quotidiens
- [ ] Notifications J+30/J+90 schedulées à la création de la décision

**Dependencies:** NotificationService, UNCalendarNotificationTrigger

---

### Story 10: Premium et monétisation
**As a** utilisateur engagé depuis 30+ jours,
**I want to** accéder aux analyses avancées et à l'historique illimité,
**So that I can** exploiter pleinement mes données accumulées.

**Acceptance Criteria:**
- [ ] Essai 7 jours sans carte bancaire (StoreKit 2 introductoryOffer)
- [ ] Moment de conversion au premier Moment de Vérité J+30
- [ ] Jamais de paywall avant la première entrée
- [ ] Jamais de pop-up premium sans raison
- [ ] Features premium : historique illimité, recherche, patterns, corrélations avancées, widgets, verrou biométrique, cloud sync, thèmes

**Dependencies:** StoreKitService, PremiumGateView

---

## Functional Requirements

### Must Have (P0) — MVP

#### REQ-001: Projet Xcode et architecture de base
**Description:** Scaffold complet du projet iOS avec SwiftUI, SwiftData, MVVM, structure de fichiers, extensions, et configuration.

**Task Breakdown:**
- Créer le projet XcodeGen avec project.yml : Small (1h)
- Configurer SwiftData ModelContainer : Small (1h)
- Créer AppState et AppRouter : Small (2h)
- Créer les extensions (Color+Mood, Date+Helpers, View+Transitions) : Small (2h)

**Dependencies:** None

---

#### REQ-002: Models SwiftData
**Description:** Tous les @Model : User, CheckIn, AccountabilityEntry, Decision, FutureLetter. Toutes les enums : Emotion, Activity, HeatmapColor, Verdict, DecisionStatus, AppTheme. Structs : NotificationSettings.

**Task Breakdown:**
- Implémenter les 5 @Model avec toutes les propriétés : Medium (4h)
- Implémenter les enums et structs : Small (2h)
- Tests unitaires des models : Small (2h)

**Dependencies:** REQ-001

---

#### REQ-003: Composant PatchiView
**Description:** Composant réutilisable PatchiView avec enum PatchiExpression (20+ expressions). Animation de respiration (oscillation verticale). Import des visuels depuis assets.

**Task Breakdown:**
- Créer PatchiExpression enum avec toutes les expressions : Small (2h)
- Créer PatchiView avec animation de respiration : Medium (3h)
- Intégrer les assets Patchi dans xcassets : Small (1h)

**Dependencies:** REQ-001, assets Patchi

---

#### REQ-004: Système de couleurs dynamiques
**Description:** Couleurs de fond qui changent selon l'humeur déclarée. 7 couleurs vives mappées aux scores/émotions. Transitions fluides 400-600ms.

**Acceptance Criteria:**
- [ ] Color+Mood avec les 7 couleurs vives du design
- [ ] Transition fluide entre couleurs
- [ ] Appliqué aux écrans check-in, cards journal, accueil

**Task Breakdown:**
- Implémenter Color+Mood.swift avec les 7 couleurs : Small (1h)
- Créer l'environnement de couleur dynamique : Small (1h)
- Animer les transitions de couleur : Small (2h)

**Dependencies:** REQ-001

---

#### REQ-005: Onboarding complet 8 étapes
**Description:** Flow de 8 écrans avec Patchi : présentation → prénom → première question → reformulation → premier carré heatmap → configuration rappels → offre d'essai → création compte.

**Task Breakdown:**
- Créer OnboardingView avec navigation entre 8 étapes : Medium (4h)
- Créer OnboardingViewModel : Medium (3h)
- Écran 1-2 : Patchi + prénom : Small (2h)
- Écran 3-4 : Première question + reformulation : Medium (3h)
- Écran 5 : Premier carré heatmap : Small (2h)
- Écran 6 : Configuration rappels (double slider) : Medium (3h)
- Écran 7 : Offre d'essai : Small (2h)
- Écran 8 : Création compte (email + Sign in with Apple) : Medium (4h)

**Dependencies:** REQ-002, REQ-003, REQ-004, REQ-008 (ReformulationService)

---

#### REQ-006: Mood Check-in
**Description:** Écran de check-in complet avec slider d'humeur, grilles d'activités et d'émotions, titre, note texte/voix, photo, reformulation Patchi.

**Task Breakdown:**
- Créer MoodSliderView avec visage Patchi animé : Medium (4h)
- Créer ActivityGridView avec 20 activités : Medium (3h)
- Créer EmotionGridView avec 20 émotions et visages Patchi : Medium (3h)
- Formulaire titre + note + photo : Medium (3h)
- Intégrer SpeechService (SFSpeechRecognizer) : Medium (4h)
- Créer CheckInViewModel : Medium (3h)
- Écran de reformulation Patchi post-check-in : Small (2h)

**Dependencies:** REQ-002, REQ-003, REQ-004, REQ-008

---

#### REQ-007: Accountability Tracker
**Description:** Question du soir avec texte libre, raison, jugement, heatmap 90 jours, option skip positive, rattrapage.

**Task Breakdown:**
- Créer AccountabilityView : Medium (3h)
- Créer AccountabilityViewModel : Medium (3h)
- Implémenter la logique skip/rattrapage : Small (2h)
- Créer HeatmapGridView et HeatmapCell : Medium (4h)
- Implémenter HeatmapService (calcul couleurs 90 jours) : Medium (3h)
- Animation heatmap (carrés un par un) : Small (2h)

**Dependencies:** REQ-002, REQ-004

---

#### REQ-008: ReformulationService
**Description:** Service 100% local qui transforme les mots-clés de l'utilisateur en phrases Patchi. Dictionary de mots-clés → phrases. Analyse tokenisée du texte.

**Task Breakdown:**
- Créer le dictionnaire de mots-clés (100+ mappings) : Medium (4h)
- Implémenter l'analyse tokenisée : Medium (3h)
- Écrire les phrases Patchi (20+ par contexte) : Medium (4h)

**Dependencies:** None

---

#### REQ-009: Journal de décisions
**Description:** Formulaire de nouvelle décision, liste de décisions avec statut, écran de verdict à J+30 et J+90, moment de vérité.

**Task Breakdown:**
- Créer NewDecisionView : Medium (3h)
- Créer DecisionListView avec filtres de statut : Medium (3h)
- Créer VerdictView (écran moment de vérité) : Medium (4h)
- Créer DecisionViewModel : Medium (3h)
- Scheduler les notifications J+30 et J+90 : Medium (3h)

**Dependencies:** REQ-002, REQ-003, REQ-010

---

#### REQ-010: NotificationService
**Description:** Service de notifications pour les 5 types : soir, décision, J+30, lettre, dimanche. Pool de 20 formulations. Scheduling via UNCalendarNotificationTrigger.

**Task Breakdown:**
- Implémenter NotificationService wrapper : Medium (3h)
- Écrire les 20 formulations du soir : Small (2h)
- Implémenter le scheduling des 5 types : Medium (4h)
- Gérer les permissions : Small (1h)

**Dependencies:** None

---

#### REQ-011: Navigation principale (5 tabs)
**Description:** TabView avec 5 onglets : Aujourd'hui, Citations, Nouveau (+), Stats, Journal. Bouton central surélevé avec menu contextuel.

**Task Breakdown:**
- Créer le TabView principal avec AppRouter : Medium (3h)
- Écran Aujourd'hui (HomeView) : Medium (4h)
- Bouton central + menu contextuel : Small (2h)

**Dependencies:** REQ-001

---

#### REQ-012: Journal et historique
**Description:** Liste chronologique de toutes les entrées, bande calendrier navigable, compteur d'entrées, cards colorées selon humeur.

**Task Breakdown:**
- Créer JournalView avec liste d'entrées : Medium (3h)
- Créer EntryCardView colorée : Medium (3h)
- Créer CalendarStripView navigable : Medium (4h)
- Créer JournalViewModel avec filtres et compteurs : Medium (3h)
- Historique 30 jours (gratuit) vs illimité (premium) : Small (2h)

**Dependencies:** REQ-002, REQ-004

---

#### REQ-013: Lettre au futur moi
**Description:** Écriture mensuelle, lettre scellée, livraison 6 mois, notification spéciale, réponse.

**Task Breakdown:**
- Créer WriteLetterView : Medium (3h)
- Créer ReadLetterView avec animation d'ouverture : Medium (4h)
- Créer LetterViewModel : Medium (3h)
- Scheduler la notification 6 mois : Small (2h)
- Logique de réponse → nouvelle lettre : Small (2h)

**Dependencies:** REQ-002, REQ-003, REQ-010

---

#### REQ-014: Statistiques et graphiques
**Description:** Heatmap 90 jours, courbes d'humeur hebdo/mensuel, corrélations simples, countdown insights.

**Task Breakdown:**
- Créer StatsView avec layout : Medium (3h)
- Implémenter MoodChartView (Swift Charts) : Medium (4h)
- Intégrer HeatmapGridView dans les stats : Small (2h)
- Implémenter InsightService (corrélations) : Medium (4h)
- Countdown vers prochains insights : Small (2h)

**Dependencies:** REQ-002, REQ-007

---

#### REQ-015: Feed de citations
**Description:** Feed swipeable plein écran, grande typo Crimson Pro italique, fond coloré par catégorie, favoris, partage.

**Task Breakdown:**
- Créer QuotesFeedView swipeable : Medium (4h)
- Base de données de citations en JSON (100+) : Medium (4h)
- Mapping humeur → catégorie de citations : Small (2h)
- Favoris + partage : Small (2h)

**Dependencies:** REQ-001

---

#### REQ-016: Défi quotidien
**Description:** Action concrète liée aux intentions de l'utilisateur, countdown jusqu'à minuit, validation.

**Task Breakdown:**
- Créer le composant DailyChallenge sur HomeView : Medium (3h)
- Pool de défis liés aux activités : Medium (3h)
- Countdown minuit : Small (1h)
- Logique de validation → heatmap : Small (2h)

**Dependencies:** REQ-002, REQ-007

---

#### REQ-017: Wisdom hebdomadaire
**Description:** Card spéciale "Mon apprentissage de la semaine : ___", archivage.

**Task Breakdown:**
- Créer le composant WeeklyWisdom sur HomeView : Small (2h)
- Logique d'archivage dans le journal : Small (1h)

**Dependencies:** REQ-002, REQ-012

---

#### REQ-018: StoreKit 2 et premium
**Description:** Gestion de l'abonnement premium, essai 7 jours sans CB, vérification des entitlements.

**Task Breakdown:**
- Créer StoreKitService : Medium (4h)
- Créer PremiumView (offre premium) : Medium (3h)
- Créer PremiumGateView (composant de verrouillage) : Small (2h)
- Configurer introductoryOffer pour trial sans CB : Small (2h)
- Vérifier Transaction.currentEntitlements au lancement : Small (1h)

**Dependencies:** REQ-001

---

#### REQ-019: Sign in with Apple
**Description:** Inscription et connexion via Apple ID. AuthenticationServices.

**Task Breakdown:**
- Implémenter Sign in with Apple : Medium (3h)
- Intégrer dans l'onboarding et les settings : Small (2h)

**Dependencies:** REQ-001

---

#### REQ-020: Questions adaptatives
**Description:** J+1 à J+3 même question, J+3 proposition d'intentions, J+4+ pool de 20 formulations différentes selon thèmes identifiés.

**Task Breakdown:**
- Implémenter la logique d'adaptation des questions : Medium (3h)
- Écrire les 20 formulations par thème : Medium (3h)
- Détection de mots-clés récurrents : Medium (3h)

**Dependencies:** REQ-002, REQ-008

---

#### REQ-021: Settings
**Description:** Page de paramètres avec configuration notifications, thème, verrou biométrique, compte, premium.

**Task Breakdown:**
- Créer SettingsView : Medium (3h)
- Créer NotificationSettingsView (double slider) : Medium (3h)
- Intégrer le verrou biométrique (BiometricService) : Medium (3h)

**Dependencies:** REQ-010, REQ-018

---

### Should Have (P1) — V1.1

#### REQ-022: Widget iOS
**Description:** Widget petit (heatmap 7 jours + décisions en attente) et grand (humeur semaine + défi). WidgetKit + AppIntents.

**Dependencies:** REQ-007, REQ-014

---

#### REQ-023: CloudKit sync premium
**Description:** Synchronisation automatique chiffrée pour utilisateurs premium. Multi-appareils.

**Dependencies:** REQ-002, REQ-018

---

#### REQ-024: Recherche mot-clé dans le journal
**Description:** Barre de recherche dans tout l'historique avec surlignage du terme trouvé. Premium.

**Dependencies:** REQ-012, REQ-018

---

#### REQ-025: Thèmes visuels premium
**Description:** Thèmes alternatifs modifiant couleurs et ambiance. Premium.

**Dependencies:** REQ-004, REQ-018

---

### Nice to Have (P2) — V2

#### REQ-026: Android
#### REQ-027: Bilan annuel narratif
#### REQ-028: Corrélations avancées
#### REQ-029: IA optionnelle pour validation des raisons d'accountability

---

## Non-Functional Requirements

### Performance
- Lancement de l'app : < 2 secondes
- Navigation entre tabs : < 100ms
- Sauvegarde d'un check-in : < 200ms (SwiftData local)
- Chargement heatmap 90 jours : < 300ms
- Animations : 60fps constant

### Security
- Données stockées localement via SwiftData (pas de serveur)
- CloudKit chiffré (premium)
- Verrou biométrique Face ID / Touch ID (premium)
- Sign in with Apple pour l'auth
- Aucune donnée envoyée à des serveurs tiers
- Pas d'IA, pas d'API externe

### Accessibility
- VoiceOver support sur tous les écrans
- Dynamic Type support
- Contrastes suffisants malgré les couleurs vives
- Labels accessibles sur tous les contrôles interactifs

### Compatibility
- iOS 17.0+
- iPhone uniquement (iPad en V2)
- SwiftUI 5.0+ / Swift 5.9+

---

## Technical Considerations

### System Architecture

```
┌─────────────────────────────────────────┐
│            PatchiApp (SwiftUI)           │
├─────────────────────────────────────────┤
│  AppState (@Observable)                  │
│  AppRouter (navigation)                  │
├─────────────────────────────────────────┤
│  Features/                               │
│  ├── Onboarding (8 étapes)              │
│  ├── Home (Aujourd'hui)                  │
│  ├── CheckIn (mood + activities)         │
│  ├── Accountability (soir + heatmap)     │
│  ├── Decisions (CRUD + verdicts)         │
│  ├── Stats (charts + insights)           │
│  ├── Journal (historique + calendrier)   │
│  ├── Letters (écrire + lire)             │
│  ├── Quotes (feed + favoris)             │
│  └── Settings (config + premium)         │
├─────────────────────────────────────────┤
│  Services/                               │
│  ├── NotificationService                 │
│  ├── SpeechService                       │
│  ├── StoreKitService                     │
│  ├── HeatmapService                      │
│  ├── ReformulationService                │
│  ├── InsightService                      │
│  ├── BiometricService                    │
│  └── CloudSyncService                    │
├─────────────────────────────────────────┤
│  Models/ (@Model SwiftData)              │
│  ├── User                                │
│  ├── CheckIn                             │
│  ├── AccountabilityEntry                 │
│  ├── Decision                            │
│  └── FutureLetter                        │
├─────────────────────────────────────────┤
│  SwiftData ModelContainer                │
│  (local) ──── CloudKit (premium only)    │
└─────────────────────────────────────────┘
```

### Data Models

```swift
@Model User {
  id: UUID, firstName: String, email: String?,
  createdAt: Date, isPremium: Bool, premiumExpiresAt: Date?,
  onboardingCompleted: Bool, notificationSettings: NotificationSettings,
  selectedTheme: AppTheme, biometricLockEnabled: Bool
}

@Model CheckIn {
  id: UUID, date: Date, moodScore: Int (1-5),
  activities: [Activity], emotions: [Emotion],
  title: String?, note: String?, photoData: Data?,
  isVoiceEntry: Bool, reformulation: String?
}

@Model AccountabilityEntry {
  id: UUID, date: Date, missedAction: String,
  reason: String?, isReasonValid: Bool?, importance: Int (1-5),
  heatmapColor: HeatmapColor, isSkipped: Bool
}

@Model Decision {
  id: UUID, title: String, context: String,
  prediction: String, decision: String, importance: Int (1-5),
  createdAt: Date, reviewAt30: Date, reviewAt90: Date,
  verdict30: Verdict?, verdict90: Verdict?,
  whatHappened30: String?, whatHappened90: String?,
  status: DecisionStatus
}

@Model FutureLetter {
  id: UUID, content: String, writtenAt: Date,
  deliverAt: Date, isDelivered: Bool,
  reply: String?, repliedAt: Date?
}
```

### Technology Stack

| Couche | Technologie |
|--------|------------|
| UI Framework | SwiftUI — iOS 17+ |
| Language | Swift 5.9 |
| Persistence | SwiftData — @Model |
| Cloud sync | CloudKit (premium) |
| State | @Observable + @Environment |
| Auth | AuthenticationServices |
| Speech | SFSpeechRecognizer + AVFoundation |
| Notifications | UserNotifications |
| Monetisation | StoreKit 2 |
| Biometrie | LocalAuthentication |
| Widget | WidgetKit + AppIntents |
| Architecture | MVVM |

---

## Implementation Roadmap

### Phase 1: Foundation (Semaine 1)
**Goal:** Projet compilable avec models, extensions, et composants de base.

- Task 1.1: Setup XcodeGen + structure projet (2h)
- Task 1.2: Models SwiftData + enums (6h)
- Task 1.3: Extensions (Color+Mood, Date+Helpers, View+Transitions) (4h)
- Task 1.4: PatchiView + expressions (6h)
- Task 1.5: AppState + AppRouter + TabView principal (5h)
- Task 1.6: Système de couleurs dynamiques (4h)

**Checkpoint:** App se lance avec 5 tabs vides et Patchi visible.

---

### Phase 2: Core Data Entry (Semaine 2-3)
**Goal:** L'utilisateur peut saisir des données.

- Task 2.1: ReformulationService (11h)
- Task 2.2: NotificationService (10h)
- Task 2.3: Mood Check-in complet (22h)
- Task 2.4: Accountability tracker + heatmap (17h)
- Task 2.5: SpeechService (entrée vocale) (4h)

**Checkpoint:** L'utilisateur peut faire un check-in et une entrée accountability.

---

### Phase 3: Decisions & Letters (Semaine 3-4)
**Goal:** Journal de décisions et lettres fonctionnels.

- Task 3.1: Journal de décisions (16h)
- Task 3.2: Lettre au futur moi (14h)
- Task 3.3: Questions adaptatives (9h)

**Checkpoint:** Toutes les saisies fonctionnent.

---

### Phase 4: Views & Navigation (Semaine 4-5)
**Goal:** Écrans de consultation et navigation complète.

- Task 4.1: Journal et historique (15h)
- Task 4.2: Stats et graphiques (15h)
- Task 4.3: Feed de citations (12h)
- Task 4.4: HomeView complet (Aujourd'hui) (9h)
- Task 4.5: Défi quotidien + Wisdom hebdomadaire (6h)
- Task 4.6: Rituel du dimanche (8h)

**Checkpoint:** Toutes les views sont fonctionnelles.

---

### Phase 5: Monetisation & Auth (Semaine 5-6)
**Goal:** Premium et auth en place.

- Task 5.1: StoreKit 2 + premium (12h)
- Task 5.2: Sign in with Apple (5h)
- Task 5.3: Settings complet (9h)
- Task 5.4: PremiumGateView + verrouillage features (4h)

**Checkpoint:** Cycle complet : inscription → essai → conversion.

---

### Phase 6: Onboarding & Polish (Semaine 6-7)
**Goal:** Onboarding complet et polish.

- Task 6.1: Onboarding 8 étapes (23h)
- Task 6.2: Animations et transitions (8h)
- Task 6.3: Typographie Crimson Pro + polishing visuel (4h)
- Task 6.4: Accessibilité (VoiceOver, Dynamic Type) (6h)

**Checkpoint:** Flow complet de A à Z testable.

---

## Out of Scope

1. **Android** — V2 après validation du concept iOS
2. **IA / LLM** — Pas dans le MVP. L'utilisateur est son propre juge.
3. **iPad** — V2
4. **Bilan annuel narratif** — V2
5. **Widget iOS** — V1.1
6. **CloudKit sync** — V1.1
7. **Backend/serveur** — Tout est local-first avec SwiftData
8. **Multi-langue** — Français uniquement pour le MVP

---

## Open Questions & Risks

### Open Questions

#### Q1: Nom définitif de l'app
- **Current Status:** "Patchi" (temporaire)
- **Deadline:** Avant soumission App Store
- **Impact:** Low (changeable dans le code)

#### Q2: Prix exact du premium
- **Current Status:** ~35€/an
- **Options:** 29.99€, 34.99€, 39.99€
- **Deadline:** Avant configuration StoreKit

#### Q3: Assets Patchi — formats d'export
- **Current Status:** Visuels créés, à exporter pour Xcode
- **Deadline:** Phase 1 (bloquant pour PatchiView)

### Risks & Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Assets Patchi pas prêts à temps | Medium | High | Utiliser des placeholder SVG, intégrer les vrais assets plus tard |
| SwiftData + CloudKit complexité | High | Medium | Commencer local-only, ajouter CloudKit en V1.1 |
| Reflectly sort une version française | Low | Critical | Lancer le MVP rapidement, se différencier par les décisions et l'accountability |
| Rejet App Store | Low | High | Suivre les guidelines, essai sans CB, pas de dark patterns |
| Performances heatmap 90 jours | Low | Medium | Optimiser les queries SwiftData, limiter les animations |

---

## Validation Checkpoints

### Checkpoint 1: Foundation (fin Phase 1)
- [ ] App compile et se lance
- [ ] 5 tabs visibles avec navigation
- [ ] PatchiView affiche les expressions
- [ ] Couleurs dynamiques fonctionnent

### Checkpoint 2: Core Data Entry (fin Phase 2)
- [ ] Check-in mood complet fonctionnel
- [ ] Accountability tracker fonctionnel
- [ ] Heatmap 90 jours s'affiche
- [ ] Reformulation Patchi apparaît

### Checkpoint 3: All Inputs (fin Phase 3)
- [ ] Décisions avec rappels J+30/J+90
- [ ] Lettres au futur moi
- [ ] Questions adaptatives

### Checkpoint 4: All Views (fin Phase 4)
- [ ] Journal navigable avec calendrier
- [ ] Stats avec graphiques
- [ ] Citations avec swipe
- [ ] HomeView complet

### Checkpoint 5: Monetisation (fin Phase 5)
- [ ] StoreKit 2 fonctionnel
- [ ] Sign in with Apple
- [ ] Premium gate sur les features payantes

### Checkpoint 6: Ready to Ship (fin Phase 6)
- [ ] Onboarding complet
- [ ] Animations fluides
- [ ] VoiceOver fonctionnel
- [ ] Flow complet testable de A à Z

---

## Appendix: Task Breakdown Hints

### Parallelizable Tasks
- Phase 1 : Tasks 1.2, 1.3, 1.4 peuvent être parallélisées
- Phase 2 : Tasks 2.1, 2.2 peuvent être parallélisées (services indépendants)
- Phase 4 : Tasks 4.1, 4.2, 4.3 peuvent être parallélisées
- Phase 5 : Tasks 5.1, 5.2 peuvent être parallélisées

### Critical Path
1.1 → 1.2 → 1.5 → 2.3 (check-in) → 3.1 (décisions) → 4.1 (journal) → 5.1 (premium) → 6.1 (onboarding)

### Total Estimated Effort
- Phase 1: ~27h
- Phase 2: ~64h
- Phase 3: ~39h
- Phase 4: ~65h
- Phase 5: ~30h
- Phase 6: ~41h
- **Total: ~266h** (~7-8 semaines à temps plein)

---

**End of PRD**

*This PRD is optimized for TaskMaster AI task generation. All requirements include task breakdown hints, complexity estimates, and dependency mapping.*
