# Project: Patchi — Journal d'intégrité personnelle

> **Taskmaster-Managed iOS Project**

## Project Overview

App iOS native en SwiftUI pour le journaling émotionnel, l'accountability personnel, et le journal de décisions. En français natif. Mascotte Patchi (petite patate orange chibi).

**Key Documents:**
- PRD: `.taskmaster/docs/prd.md` - Product requirements complets
- Tasks: `.taskmaster/tasks/tasks.json` - 40 tâches avec dépendances
- Spec originale: `Application iOS Journal de Décisions.md`

---

## Tech Stack

| Couche | Technologie |
|--------|------------|
| UI Framework | SwiftUI — iOS 17+ |
| Language | Swift 5.9 |
| Persistence | SwiftData — @Model |
| Cloud sync | CloudKit (premium only, V1.1) |
| State | @Observable + @Environment |
| Auth | AuthenticationServices (Sign in with Apple) |
| Speech | SFSpeechRecognizer + AVFoundation |
| Notifications | UserNotifications |
| Monetisation | StoreKit 2 |
| Biometrie | LocalAuthentication |
| Widget | WidgetKit + AppIntents (V1.1) |
| Architecture | MVVM |
| Build | XcodeGen |

## Architecture

```
Patchi/
├── App/          → PatchiApp.swift, AppState, AppRouter
├── Models/       → @Model SwiftData (User, CheckIn, AccountabilityEntry, Decision, FutureLetter)
│   └── Enums/    → Emotion, Activity, HeatmapColor, Verdict, DecisionStatus, AppTheme
├── Features/     → Un dossier par feature (View + ViewModel)
│   ├── Onboarding/
│   ├── Home/
│   ├── CheckIn/
│   ├── Accountability/
│   ├── Decisions/
│   ├── Stats/
│   ├── Journal/
│   ├── Letters/
│   ├── Quotes/
│   └── Settings/
├── Services/     → NotificationService, SpeechService, StoreKitService, HeatmapService,
│                   ReformulationService, InsightService, BiometricService, CloudSyncService
├── Components/   → Patchi/, HeatmapGrid/, MoodSlider/, VoiceInput/, PremiumGate/, CalendarStrip/
├── Extensions/   → Color+Mood, Date+Helpers, View+Transitions
└── Resources/    → Localizable.strings, Assets.xcassets, Fonts/
```

## Décisions clés

- **Pas d'IA** — L'utilisateur est son propre juge. Zéro coût API, zéro dépendance externe.
- **Local-first** — SwiftData pour tous. CloudKit uniquement pour premium.
- **Français natif** — Tout en français, pas traduit. Patchi tutoie.
- **Couleurs vives** — Palette saturée et énergique pour les couleurs d'humeur.
- **Freemium** — Toutes les saisies gratuites, analyses avancées en premium (~35€/an).
- **StoreKit 2** — Trial 7 jours sans CB via introductoryOffer.
- **Conversion au J+30** — Premier moment de vérité = meilleur moment de conversion.

## Typographie

- **Crimson Pro italique** — Titres, questions Patchi, citations, reformulations (émotionnel)
- **SF Pro (système)** — Labels, data, interface (fonctionnel)

## Couleurs d'humeur (vives)

| Score | Couleur |
|-------|---------|
| 5 | Jaune soleil vif |
| 4 | Vert émeraude franc |
| 3 | Beige chaud |
| 2 | Violet doux |
| 1 | Bleu nuit profond |
| Stress | Orange vif |
| Colère | Rouge corail |

## Taskmaster Commands

```bash
task-master list                     # Voir toutes les tâches
task-master show <id>                # Détails d'une tâche
task-master next                     # Prochaine tâche disponible
task-master set-status --id=<id> --status=in-progress
task-master set-status --id=<id> --status=done
```

## Règles

- Lire le PRD (`.taskmaster/docs/prd.md`) au début de chaque conversation
- Toutes les données sensibles en local uniquement (SwiftData)
- Ne jamais utiliser `rm` — utiliser `trash` à la place
- Utiliser `/swiftui-pro` pour review le code SwiftUI
- Utiliser `/verification-before-completion` avant de commit
