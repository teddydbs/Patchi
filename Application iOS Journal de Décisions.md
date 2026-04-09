## Journal d'intégrité personnelle — App iOS

**Version 1.0 — Avril 2026**
iOS 17+ · SwiftUI · SwiftData · MVVM

---

## Table des matières

1. [Résumé exécutif](#1-résumé-exécutif)
2. [Vision & Positionnement](#2-vision--positionnement)
3. [Utilisateur cible](#3-utilisateur-cible)
4. [Kokora — La mascotte](#4-kokora--la-mascotte)
5. [Identité visuelle](#5-identité-visuelle)
6. [Onboarding](#6-onboarding)
7. [Navigation](#7-navigation)
8. [Features complètes](#8-features-complètes)
9. [Monétisation](#9-monétisation)
10. [Rétention](#10-rétention)
11. [Architecture technique](#11-architecture-technique)
12. [Décisions produit arrêtées](#12-décisions-produit-arrêtées)
13. [Roadmap MVP](#13-roadmap-mvp)
14. [Ce qui reste à décider](#14-ce-qui-reste-à-décider)

---

## 1. Résumé exécutif

Cette app est un journal de vie intelligent, en français natif, conçu pour iPhone. Elle combine trois dimensions qu'aucune application n'offre ensemble aujourd'hui : le journaling émotionnel quotidien, un système d'accountability personnel, et un journal de décisions avec rappel dans le temps.

L'application s'adresse aux personnes en construction active de soi — entrepreneurs, étudiants ambitieux, personnes traversant une période de changement. Elle leur permet de capturer ce qu'ils ressentent, de se confronter honnêtement à l'écart entre leurs intentions et leur réalité, et de préserver leurs décisions importantes pour les revisiter au bon moment.

Le marché francophone est non servi. Le leader mondial du journaling, avec 13 millions d'utilisateurs, est exclusivement en anglais. Les avis des utilisateurs francophones convergent sur un point : l'absence de version française est le principal frein. Cette application comble ce vide avec un produit supérieur, pensé en français dès le premier mot.

| Critère    | Valeur                                                               |
| ---------- | -------------------------------------------------------------------- |
| Plateforme | iOS 17+ (Android en V2)                                              |
| Langue     | Français natif — pensé en français, pas traduit                      |
| Modèle     | Freemium — gratuit avec accès core, premium ~35€/an                  |
| Mascotte   | Kokora — petite patate ronde orange, style chibi, visuels déjà créés |
| Tech stack | SwiftUI · SwiftData · CloudKit · StoreKit 2 · MVVM                   |

---

## 2. Vision & Positionnement

### 2.1 La vision

On prend des décisions chaque jour. On ressent des choses chaque soir. Mais on oublie presque tout — le contexte, ce qu'on pensait, ce qu'on espérait. Et quelques mois plus tard on doute, on regrette, on se demande si on avait fait les bons choix.

Cette application est un journal vivant. Elle capture ce que l'utilisateur vit, ce qu'il décide, ce qu'il aurait voulu faire. Et elle lui rend ces informations au bon moment — pas comme un reproche, mais comme un miroir honnête et bienveillant.

Elle ne juge pas. Elle observe. Elle se souvient. Elle aide l'utilisateur à se voir tel qu'il est vraiment.

> **Les autres apps te demandent comment tu te sens. Celle-ci te demande qui tu es en train de devenir.**

### 2.2 Le positionnement

| Feature                  | Disponibilité |
| ------------------------ | ------------- |
| Journaling émotionnel    | Gratuit       |
| Accountability quotidien | Gratuit       |
| Journal de décisions     | Gratuit       |
| Français natif           | Gratuit       |
| Mascotte Kokora          | Gratuit       |
| Lettre au futur moi      | Gratuit       |

### 2.3 Analyse concurrentielle

| Critère             | Concurrent A | Day One | Cette app |
| ------------------- | ---------- | ------- | --------- |
| Français natif      | ❌         | ❌      | ✅        |
| Journal décisions   | ❌         | ❌      | ✅        |
| Accountability      | ❌         | ❌      | ✅        |
| Lettre au futur moi | ❌         | ❌      | ✅        |
| Mascotte expressive | ✅ basique | ❌      | ✅ Kokora |
| Heatmap progression | ❌         | ❌      | ✅        |
| Mood tracker        | ✅         | ✅      | ✅        |
| Couleurs dynamiques | ❌         | ❌      | ✅        |
| Prix premium/an     | ~60€       | ~35€    | ~35€      |

---

## 3. Utilisateur cible

### 3.1 Persona principal

L'utilisateur cible est en construction active de soi. Il veut devenir une meilleure version de lui-même et est prêt à se confronter à ses propres incohérences pour y arriver.

- Entrepreneur ou freelance qui prend des décisions importantes régulièrement
- Étudiant ambitieux en grande école ou université
- Personne traversant une période de changement — reconversion, séparation, déménagement, nouveau job
- 25-40 ans, smartphone-first, habitué aux apps de productivité
- Francophone — France, Belgique, Suisse, Canada, Afrique francophone
- A déjà essayé un journal ou une app de méditation mais n'a pas persévéré

### 3.2 Besoins fondamentaux

- Se sentir entendu et reconnu dans ses émotions quotidiennes
- Avoir un endroit pour poser ses décisions importantes sans les oublier
- Se confronter honnêtement à lui-même sans se sentir jugé
- Voir sa progression dans le temps de façon visible et motivante
- Retrouver ce qu'il pensait il y a 30, 90 jours

### 3.3 Frustrations actuelles

- Les apps leaders du journaling sont en anglais et ne sont pas adaptées à la culture française
- Les apps de journaling generic sont trop vagues — elles demandent comment tu vas sans creuser pourquoi
- Pas d'app qui connecte les décisions passées avec le présent
- Les streaks punissent au lieu de motiver — si on rate un jour on abandonne

---

## 4. Kokora — La mascotte

### 4.1 Description physique

Kokora est une petite patate ronde et orange. Son corps est ovale légèrement triangulaire arrondi par le bas — stable, ancré, solide. Sa peau est orange vif et chaleureux, avec de petits bras et jambes expressifs. Ses yeux sont deux grands cercles noirs brillants avec des reflets blancs qui lui donnent une vie immédiate. Deux petites joues rosées permanentes. Une bouche simple et expressive qui change selon les contextes.

> Les visuels de Kokora sont déjà créés et validés.

### 4.2 Style graphique

- Style chibi — proportions exagérées, grosse tête, corps petit
- Traits épais et arrondis
- Couleur principale : orange vif et chaud
- 20+ expressions différentes couvrant tout le spectre émotionnel
- Généré en style anime/chibi --niji 6

### 4.3 Personnalité et ton de voix

Kokora ne parle pas beaucoup. C'est sa force. Quand elle apparaît dans l'app, c'est que quelque chose d'important se passe. Elle dit peu. Elle dit juste.

- Tutoie l'utilisateur
- Sobre et directe — jamais d'exclamations excessives
- Bienveillante mais pas condescendante
- Ne félicite pas pour rien, ne punit pas non plus

**Exemples de phrases de Kokora :**

- _"C'est noté."_ — après une entrée
- _"Tu y es. Reviens demain."_ — confirmation de streak
- _"30 jours. Tu avais vu juste ?"_ — moment de vérité
- _"Cette semaine tu as beaucoup pensé à quelque chose."_ — insight hebdomadaire
- _"La lettre est arrivée. Elle t'attendait."_ — livraison de lettre
- _"Hé. C'est ok de pas avoir tout réussi."_ — après une mauvaise journée

### 4.4 Présence dans l'app

Kokora n'est pas omniprésente. Elle apparaît dans des moments précis et significatifs :

- Onboarding — premier contact, présentation
- Après chaque check-in — reformulation de 3 secondes puis disparaît
- Moment de vérité J+30 / J+90 — accompagne le verdict
- Rituel du dimanche — guide le bilan hebdomadaire
- Livraison de lettre — ouvre l'enveloppe avec l'utilisateur
- Paliers d'insights — annonce chaque nouvelle découverte

---

## 5. Identité visuelle

### 5.1 Direction artistique

Le design s'inspire d'apps de journaling modernes — Bear, Finch — avec des cards arrondies, de grandes typographies, beaucoup d'espace, et une navigation intuitive. La différence principale est le système de couleurs dynamiques selon l'humeur et la présence de Kokora.

### 5.2 Système de couleurs dynamiques selon l'humeur

La couleur de fond de l'écran change selon l'humeur déclarée. Ce changement s'applique aux écrans de mood check-in, aux cards d'entrée dans le journal, et à l'écran d'accueil après un check-in.

| Humeur       | Score | Couleur de fond     | Description                  |
| ------------ | ----- | ------------------- | ---------------------------- |
| Très heureux | 5/5   | Jaune soleil vif    | Lumineux, énergique, solaire |
| Heureux      | 4/5   | Vert émeraude franc | Saturé, vif, positif         |
| Neutre       | 3/5   | Beige chaud         | Ni positif ni négatif        |
| Triste       | 2/5   | Violet doux         | Introspectif, enveloppant    |
| Très triste  | 1/5   | Bleu nuit profond   | Profond, calme, sécurisant   |
| Stressé      | —     | Orange vif          | Alerte sans agressivité      |
| En colère    | —     | Rouge corail        | Intense mais pas brutal      |

### 5.3 Heatmap — code couleur

| Couleur    | Signification                                         |
| ---------- | ----------------------------------------------------- |
| Rouge      | Raison non valable, mauvaise journée d'accountability |
| Orange     | Raison valable mais action non réalisée               |
| Vert clair | Accompli avec effort                                  |
| Vert foncé | Accompli facilement                                   |

L'intensité du carré reflète l'importance déclarée de l'action (1 à 5 étoiles).

### 5.4 Typographie

- **Crimson Pro italique** — titres, questions de Kokora, citations, reformulations. Tout ce qui est émotionnel.
- **SF Pro (système iOS)** — labels, data, interface. Tout ce qui est fonctionnel.

### 5.5 Animations

- Transitions lentes et organiques — 400-600ms, easing naturel
- Heatmap — carrés apparaissent un par un de gauche à droite
- Reformulation — texte apparaît mot par mot
- Changement couleur humeur — transition fluide, jamais brusque
- Kokora — légère oscillation verticale permanente, elle "respire"
- Mode jour → nuit — interface s'assombrit légèrement le soir

---

## 6. Onboarding

### 6.1 Principes

- L'onboarding ne parle pas de l'app — il parle de l'utilisateur
- Valeur immédiate avant toute inscription
- Création de compte après la première entrée uniquement
- Essai premium sans carte bancaire
- Maximum 3 minutes du début à la fin

### 6.2 Flow complet

| #   | Étape             | Contenu & logique                                                                                                       |
| --- | ----------------- | ----------------------------------------------------------------------------------------------------------------------- |
| 1   | Kokora apparaît   | Plein écran coloré. Kokora flotte doucement. _"Salut. Moi c'est Kokora."_ Bouton : _"Salut Kokora !"_                   |
| 2   | Prénom            | Kokora demande : _"Et toi, comment tu t'appelles ?"_ Champ texte unique. Utilisé partout ensuite.                       |
| 3   | Première question | Grande typographie italique. _"Aujourd'hui, qu'est-ce qui t'a manqué ?"_ Texte libre. Pas de placeholder biaisé.        |
| 4   | Reformulation     | Kokora reformule en vérité. _"sport"_ → _"Tu veux prendre soin de toi."_ Grande typo sur fond coloré. 3 secondes.       |
| 5   | Premier carré     | Heatmap vide avec 1 carré allumé — aujourd'hui. Kokora : _"Jour 1. Reviens demain."_                                    |
| 6   | Rappels           | Double slider heure début/fin. Nombre de rappels configurable. Kokora : _"Je t'enverrai un signe quand c'est l'heure."_ |
| 7   | Offre d'essai     | Sobre. _"7 jours pour voir si ça te parle. Pas de carte bancaire."_ Bouton Essayer + lien Continuer sans abonnement.    |
| 8   | Création compte   | Kokora : _"Pour ne rien perdre, crée ton espace."_ Email + mot de passe. Sign in with Apple disponible.                 |

---

## 7. Navigation

### 7.1 Structure — 5 tabs

| Tab | Nom         | Contenu                                                                                                                                                                                  |
| --- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ☀️  | Aujourd'hui | Écran d'accueil. Date en Crimson Pro italique. Bande calendrier semaine. Défi quotidien avec countdown. Wisdom hebdomadaire si applicable. Citations du moment. Kokora discrète en haut. |
| 💬  | Citations   | Feed swipeable plein écran. Grande typo italique. Fond coloré selon catégorie. Catégories filtrables. Favori + partage.                                                                  |
| ＋  | Nouveau     | Bouton central surélevé. Menu contextuel : Mood check-in · Nouvelle décision · Lettre au futur moi.                                                                                      |
| 📈  | Stats       | Heatmap 90 jours. Graphiques d'humeur hebdo et mensuel. Corrélations activités ↔ humeur. Countdown vers prochains insights. Stats de décisions (premium).                                |
| 📋  | Journal     | Toutes les entrées chronologiques. Bande calendrier navigable. Compteur reflections / check-ins / photos. Cards colorées selon humeur du jour.                                           |

---

## 8. Features complètes

### 8.1 Mood check-in quotidien

| Feature               | Description                                                                                                                                | Accès   |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ------- |
| Slider d'humeur       | Curseur avec visage Kokora animé de 1 (épuisé) à 5 (en feu). Couleur de fond change en temps réel. Plusieurs check-ins par jour possibles. | Gratuit |
| Sélection d'activités | Grille scrollable. Jusqu'à 10 sélectionnables. 20 activités proposées + création personnalisée après J+7.                                  | Gratuit |
| Sélection d'émotions  | Grille scrollable. Jusqu'à 10 sélectionnables. 20 émotions avec visage Kokora correspondant.                                               | Gratuit |
| Titre optionnel       | Une ligne pour nommer l'entrée.                                                                                                            | Gratuit |
| Note libre            | Texte illimité ou enregistrement vocal via SFSpeechRecognizer iOS natif.                                                                   | Gratuit |
| Photo optionnelle     | 1 photo par entrée depuis galerie ou caméra.                                                                                               | Gratuit |
| Reformulation Kokora  | Après check-in, Kokora traduit les mots de l'utilisateur en vérité sur lui. 3 secondes puis disparaît.                                     | Gratuit |

### 8.2 Liste des activités

Travail · Famille · Amis · Sport · Santé · Projet personnel · Repos · Voyage · Musique · Lecture · Cuisine · Nature · Méditation · Shopping · Jeux · Hobbies · École · Relation amoureuse · Sorties · Bénévolat

> L'utilisateur peut créer des catégories personnalisées après 7 jours d'utilisation.

### 8.3 Liste des émotions (20)

Heureux · Béni · Bien · Chanceux · Excité · Confus · Ennuyé · Gêné · Partagé · Nostalgique · Stressé · Dépassé · Anxieux · Agité · Frustré · En colère · Triste · Déçu · Épuisé · Seul

### 8.4 Entrée par la voix

| Feature              | Description                                                                                                                                     | Accès   |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| Transcription vocale | Bouton microphone dans tous les champs texte. SFSpeechRecognizer iOS natif — aucune API externe. Transcription en temps réel, modifiable après. | Gratuit |

### 8.5 Journal de décisions

| Feature           | Description                                                                                                                     | Accès   |
| ----------------- | ------------------------------------------------------------------------------------------------------------------------------- | ------- |
| Nouvelle décision | 3 champs : contexte, prédiction, décision prise. Titre + importance 1-5 étoiles.                                                | Gratuit |
| Boucles ouvertes  | Chaque décision non reviewée crée une card "en attente de verdict" visible dans le journal.                                     | Gratuit |
| Rappel J+30       | Notification contextuelle avec titre de la décision à 30 jours exactement. Écran dédié avec décision originale + champ verdict. | Gratuit |
| Rappel J+90       | Idem à 90 jours. Verdict : j'avais raison / partiellement / tort.                                                               | Gratuit |
| Moment de vérité  | Écran soigné : décision originale, prédiction, verdict, ce qui s'est passé. Kokora présente. Moment de conversion vers premium. | Gratuit |

### 8.6 Accountability tracker

| Feature              | Description                                                                                                         | Accès   |
| -------------------- | ------------------------------------------------------------------------------------------------------------------- | ------- |
| Question du soir     | _"Qu'aurais-tu aimé faire aujourd'hui que tu n'as pas fait ?"_ Texte libre + raison + jugement valable/non valable. | Gratuit |
| Heatmap 90 jours     | Carrés colorés rouge → vert selon résultat. Intensité = importance 1-5. Animation feuilles qui tombent.             | Gratuit |
| Option skip positive | Bouton _"Aujourd'hui tout allait bien"_ — compte comme entrée positive, évite la culpabilité.                       | Gratuit |
| Rattrapage           | Si jour raté, l'app demande le lendemain ce qui s'est passé.                                                        | Gratuit |

### 8.7 Questions adaptatives

| Feature      | Description                                                                                                                       | Accès   |
| ------------ | --------------------------------------------------------------------------------------------------------------------------------- | ------- |
| J+1 à J+3    | Même question chaque soir : _"Qu'est-ce qui t'a manqué aujourd'hui ?"_ Analyse des mots-clés.                                     | Gratuit |
| J+3          | Kokora propose des intentions basées sur les mots récurrents. _"Tu sembles penser souvent à ton corps. Tu veux qu'on suive ça ?"_ | Gratuit |
| J+4 et après | Pool de 20 formulations différentes selon les thèmes identifiés. Templates intelligents, aucune IA.                               | Gratuit |

### 8.8 Lettre au futur moi

| Feature   | Description                                                                                          | Accès   |
| --------- | ---------------------------------------------------------------------------------------------------- | ------- |
| Écriture  | Une fois par mois, Kokora invite à écrire une lettre à soi dans 6 mois. Scellée après envoi.         | Gratuit |
| Livraison | Notification spéciale 6 mois jour pour jour. _"Une lettre t'attendait."_ Animation d'ouverture.      | Gratuit |
| Réponse   | L'utilisateur peut répondre à son passé. Cette réponse devient une nouvelle lettre pour dans 6 mois. | Gratuit |

### 8.9 Citations & inspiration

| Feature                  | Description                                                                                                          | Accès       |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------- | ----------- |
| Feed citations           | Swipeable plein écran. Fond coloré selon catégorie. Catégories : courage, décision, soi, relations, travail, nature. | Gratuit     |
| Citations adaptées       | Si humeur basse → citations différentes qu'humeur haute. Mapping mood → catégorie, sans IA.                          | Gratuit     |
| Favoris                  | Sauvegarde d'une citation dans un espace dédié.                                                                      | Gratuit     |
| Partage                  | Partage vers réseaux sociaux en 1 tap avec mise en page de l'app.                                                    | Gratuit     |
| Citations personnalisées | Feed personnalisé basé sur l'historique de l'utilisateur.                                                            | **Premium** |

### 8.10 Rituel du dimanche

| Feature                 | Description                                                                                                                              | Accès   |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ------- |
| Session guidée          | Chaque dimanche soir, mode spécial. Session 5-7 min. Kokora guide le bilan.                                                              | Gratuit |
| Questions contextuelles | L'app relit les entrées de la semaine et pose des questions dessus. _"Lundi tu semblais épuisé. Est-ce que ça a changé quelque chose ?"_ | Gratuit |

### 8.11 Wisdom hebdomadaire

| Feature            | Description                                                                       | Accès   |
| ------------------ | --------------------------------------------------------------------------------- | ------- |
| Phrase à compléter | Une fois par semaine, card spéciale. _"Mon apprentissage de la semaine : \_\_\_"_ | Gratuit |
| Archivage          | Toutes les wisdom complétées sont archivées dans le journal.                      | Gratuit |

### 8.12 Défi quotidien

| Feature      | Description                                                                                       | Accès   |
| ------------ | ------------------------------------------------------------------------------------------------- | ------- |
| Défi du jour | Action concrète liée aux intentions de l'utilisateur. Pas des affirmations — des actions réelles. | Gratuit |
| Countdown    | Compte à rebours jusqu'à minuit visible sur l'écran d'accueil.                                    | Gratuit |
| Validation   | L'utilisateur valide ou passe. La validation alimente la heatmap.                                 | Gratuit |

### 8.13 Graphiques d'humeur

| Feature               | Description                                                                                  | Accès       |
| --------------------- | -------------------------------------------------------------------------------------------- | ----------- |
| Courbe hebdomadaire   | Humeur moyenne par jour sur 7 jours. Activités les plus fréquentes en dessous.               | Gratuit     |
| Courbe mensuelle      | Hauts et bas identifiés sur 30 jours.                                                        | Gratuit     |
| Corrélations simples  | _"Tu es souvent mieux quand tu bouges."_ — mapping automatique activités + humeur.           | Gratuit     |
| Corrélations avancées | Analyses fines : jours difficiles récurrents, émotions combinées, impact de chaque activité. | **Premium** |

### 8.14 Countdown vers les insights

| Palier    | Contenu                                                                | Accès       |
| --------- | ---------------------------------------------------------------------- | ----------- |
| J+1 à J+3 | _"Encore X check-ins avant tes premiers patterns."_ Countdown visible. | Gratuit     |
| J+3       | Première micro-observation de Kokora.                                  | Gratuit     |
| J+7       | Deuxième insight — tendances d'humeur de la semaine.                   | Gratuit     |
| J+30      | Patterns complets — thèmes récurrents, activités impactantes.          | **Premium** |

### 8.15 Notifications

| Type          | Description                                                                                             | Accès   |
| ------------- | ------------------------------------------------------------------------------------------------------- | ------- |
| Soir          | Pool de 20 formulations différentes. Heure configurable. _"Comment s'est passée ta journée ?"_          | Gratuit |
| Décision      | Mentionne le titre réel et le nombre de jours. _"Ta décision sur X — encore 2 jours avant le verdict."_ | Gratuit |
| J+30          | Spéciale, différente visuellement. Arrive à l'heure exacte du 30ème jour.                               | Gratuit |
| Lettre        | 6 mois jour pour jour. _"Quelqu'un t'a écrit. Tu le connais bien."_                                     | Gratuit |
| Dimanche      | 19h00. _"Le rituel de la semaine t'attend."_                                                            | Gratuit |
| Double slider | Configuration plage horaire + nombre de rappels quotidiens.                                             | Gratuit |

### 8.16 Journal & historique

| Feature             | Description                                                                    | Accès       |
| ------------------- | ------------------------------------------------------------------------------ | ----------- |
| Historique 30 jours | Accès aux 30 derniers jours d'entrées.                                         | Gratuit     |
| Historique illimité | Accès à toutes les entrées depuis J+1.                                         | **Premium** |
| Bande calendrier    | Navigation via bande calendrier scrollable. Point de couleur sous chaque jour. | Gratuit     |
| Compteur d'entrées  | Nombre de reflections / check-ins / photos accumulés.                          | Gratuit     |
| Édition entrées     | Modification possible jusqu'à 24h après création. Ensuite verrouillée.         | Gratuit     |
| Recherche mot-clé   | Barre de recherche dans tout l'historique. Surlignage du terme trouvé.         | **Premium** |

### 8.17 Streak et progression

| Feature             | Description                                                      | Accès   |
| ------------------- | ---------------------------------------------------------------- | ------- |
| Compteur de reviews | _"Tu as reviewé X décisions cette année."_ Positif et cumulatif. | Gratuit |
| Palier J+30         | 30 jours consécutifs débloquent une Wisdom spéciale de Kokora.   | Gratuit |

### 8.18 Sécurité & données

| Feature            | Description                                                         | Accès       |
| ------------------ | ------------------------------------------------------------------- | ----------- |
| Sign in with Apple | Inscription et connexion simplifiée via Apple ID.                   | Gratuit     |
| Stockage local     | Toutes les données stockées localement via SwiftData.               | Gratuit     |
| Verrou biométrique | Face ID / Touch ID pour protéger l'accès à l'app.                   | **Premium** |
| Sauvegarde cloud   | Synchronisation automatique chiffrée via CloudKit. Multi-appareils. | **Premium** |

### 8.19 Widget iOS

| Feature      | Description                                                    | Accès       |
| ------------ | -------------------------------------------------------------- | ----------- |
| Widget petit | Heatmap des 7 derniers jours + nombre de décisions en attente. | **Premium** |
| Widget grand | Humeur moyenne de la semaine + défi du jour.                   | **Premium** |

### 8.20 Bilan annuel

| Feature        | Description                                                                                                               | Accès       |
| -------------- | ------------------------------------------------------------------------------------------------------------------------- | ----------- |
| Bilan narratif | Chaque année à la date d'anniversaire : récit de progression, décisions, patterns, accomplissements. Présenté par Kokora. | **Premium** |

### 8.21 Personnalisation

| Feature                  | Description                                                                  | Accès       |
| ------------------------ | ---------------------------------------------------------------------------- | ----------- |
| Thèmes visuels           | Thème par défaut gratuit. Thèmes alternatifs modifiant couleurs et ambiance. | **Premium** |
| Activités personnalisées | Créer ses propres catégories d'activités après J+7.                          | Gratuit     |

---

## 9. Monétisation

### 9.1 Philosophie

Laisser l'utilisateur accumuler de la valeur gratuitement pendant 30-60 jours, puis lui proposer d'analyser. À ce stade, il a de la data personnelle dans l'app — le switching cost est élevé et la proposition payante est évidente.

### 9.2 Offre gratuite — forever

- Toutes les saisies illimitées (check-ins, décisions, lettres)
- Heatmap 90 jours complète
- Graphiques d'humeur hebdomadaires et mensuels
- Reformulations Kokora
- Citations, défi quotidien, wisdom hebdomadaire
- Lettre au futur moi + livraison 6 mois
- Rituel du dimanche
- Rappels configurables — 5 types
- Historique 30 derniers jours
- Streak et compteurs
- Bande calendrier
- Édition des entrées (24h)
- Sign in with Apple

### 9.3 Offre Premium — ~35€/an

- Historique complet illimité
- Recherche par mot-clé dans toutes les entrées
- Patterns de regrets après 30 jours
- Stats de décisions avancées
- Corrélations avancées activités/humeur
- Citations personnalisées
- Bilan annuel narratif
- Widget iOS (petit et grand)
- Verrou biométrique Face ID / Touch ID
- Sauvegarde cloud chiffrée automatique (CloudKit)
- Thèmes visuels supplémentaires

### 9.4 Moment de conversion

Le moment idéal est le premier Moment de Vérité à J+30. La proposition premium apparaît à ce moment précis et nulle part ailleurs — sauf à l'étape 7 de l'onboarding.

**Règles strictes :**

- Jamais de paywall avant la première entrée
- Jamais de pop-up premium entre deux écrans sans raison
- L'essai 7 jours ne demande pas de carte bancaire
- StoreKit 2 — `introductoryOffer` pour le trial sans CB

---

## 10. Rétention

| Mécanique                   | Comment ça fonctionne                                                                               |
| --------------------------- | --------------------------------------------------------------------------------------------------- |
| Heatmap visuelle            | Progression rouge → vert sur 90 jours. Voir ses carrés évoluer est une récompense en soi.           |
| Boucles ouvertes            | Chaque décision non reviewée = card visible dans le journal. Psychologiquement difficile à ignorer. |
| Insights progressifs        | Valeur à J+3, J+7, J+30. L'utilisateur ne reste jamais longtemps sans feedback de Kokora.           |
| Lettre au futur moi         | Driver long terme le plus puissant. Une fois qu'on a écrit une lettre, on revient dans 6 mois.      |
| Widget iOS                  | Présence passive sur l'écran d'accueil. _"2 décisions en attente de verdict."_                      |
| Notifications contextuelles | Jamais génériques. Mentionnent toujours le contenu réel de l'utilisateur. 5 types distincts.        |

---

## 11. Architecture technique

### 11.1 Stack

| Couche           | Technologie                                  |
| ---------------- | -------------------------------------------- |
| UI Framework     | SwiftUI — iOS 17+                            |
| Language         | Swift 5.9                                    |
| Persistence      | SwiftData — modèles `@Model`                 |
| Cloud sync       | CloudKit (premium uniquement)                |
| State management | `@Observable` + `@Environment` — iOS 17      |
| Auth             | AuthenticationServices — Sign in with Apple  |
| Speech           | SFSpeechRecognizer + AVFoundation            |
| Notifications    | UserNotifications — UNUserNotificationCenter |
| Monétisation     | StoreKit 2                                   |
| Biométrie        | LocalAuthentication — Face ID / Touch ID     |
| Widget           | WidgetKit + AppIntents                       |
| Architecture     | MVVM — ViewModels `@Observable`              |

### 11.2 Data Models SwiftData

```swift
// User
@Model User {
  id: UUID
  firstName: String
  email: String?
  createdAt: Date
  isPremium: Bool
  premiumExpiresAt: Date?
  onboardingCompleted: Bool
  notificationSettings: NotificationSettings
  selectedTheme: AppTheme
  biometricLockEnabled: Bool
}

// CheckIn
@Model CheckIn {
  id: UUID
  date: Date
  moodScore: Int            // 1-5
  activities: [Activity]
  emotions: [Emotion]
  title: String?
  note: String?
  photoData: Data?
  isVoiceEntry: Bool
  reformulation: String?    // phrase Kokora
}

// AccountabilityEntry
@Model AccountabilityEntry {
  id: UUID
  date: Date
  missedAction: String
  reason: String?
  isReasonValid: Bool?
  importance: Int           // 1-5
  heatmapColor: HeatmapColor  // red/orange/lightGreen/darkGreen
  isSkipped: Bool           // "tout allait bien"
}

// Decision
@Model Decision {
  id: UUID
  title: String
  context: String
  prediction: String
  decision: String
  importance: Int           // 1-5
  createdAt: Date
  reviewAt30: Date
  reviewAt90: Date
  verdict30: Verdict?       // right/partial/wrong
  verdict90: Verdict?
  whatHappened30: String?
  whatHappened90: String?
  status: DecisionStatus    // pending/reviewed30/reviewed90
}

// FutureLetter
@Model FutureLetter {
  id: UUID
  content: String
  writtenAt: Date
  deliverAt: Date           // writtenAt + 6 mois
  isDelivered: Bool
  reply: String?
  repliedAt: Date?
}
```

### 11.3 Enums & structs

```swift
enum Emotion: String, Codable, CaseIterable
enum Activity: String, Codable, CaseIterable
enum HeatmapColor: String, Codable
enum Verdict: String, Codable        // right / partial / wrong
enum DecisionStatus: String, Codable // pending / reviewed30 / reviewed90
enum AppTheme: String, Codable
struct NotificationSettings: Codable
extension Color { static func mood(score: Int) -> Color }
```

### 11.4 ViewModels @Observable

```
HomeViewModel
CheckInViewModel
DecisionViewModel
AccountabilityViewModel
StatsViewModel
JournalViewModel
LetterViewModel
OnboardingViewModel
SettingsViewModel
```

### 11.5 Services

```
NotificationService    → scheduling des 5 types via UNCalendarNotificationTrigger
SpeechService          → wrapper SFSpeechRecognizer avec gestion permissions
StoreKitService        → produits, trial, Transaction.currentEntitlements
HeatmapService         → calcul couleurs et données sur 90 jours
ReformulationService   → dictionary mots-clés → phrases Kokora, 100% local
InsightService         → patterns et corrélations sur les entrées
BiometricService       → LocalAuthentication wrapper
CloudSyncService       → CloudKit sync uniquement pour users premium
```

### 11.6 Structure des fichiers

```
App/
  AppNameApp.swift
  AppState.swift
  AppRouter.swift

Models/
  User.swift
  CheckIn.swift
  AccountabilityEntry.swift
  Decision.swift
  FutureLetter.swift
  Enums/
    Emotion.swift
    Activity.swift
    HeatmapColor.swift
    Verdict.swift

Features/
  Onboarding/
    OnboardingView.swift
    OnboardingViewModel.swift
  Home/
    HomeView.swift
    HomeViewModel.swift
  CheckIn/
    CheckInView.swift
    MoodSliderView.swift
    ActivityGridView.swift
    EmotionGridView.swift
    CheckInViewModel.swift
  Accountability/
    AccountabilityView.swift
    AccountabilityViewModel.swift
  Decisions/
    DecisionListView.swift
    NewDecisionView.swift
    VerdictView.swift
    DecisionViewModel.swift
  Stats/
    StatsView.swift
    HeatmapView.swift
    MoodChartView.swift
    StatsViewModel.swift
  Journal/
    JournalView.swift
    EntryCardView.swift
    JournalViewModel.swift
  Letters/
    WriteLetterView.swift
    ReadLetterView.swift
    LetterViewModel.swift
  Quotes/
    QuotesFeedView.swift
  Settings/
    SettingsView.swift
    PremiumView.swift
    NotificationSettingsView.swift

Services/
  NotificationService.swift
  SpeechService.swift
  StoreKitService.swift
  HeatmapService.swift
  ReformulationService.swift
  InsightService.swift
  BiometricService.swift
  CloudSyncService.swift

Components/
  Kokora/
    KokoraView.swift
    KokoraExpression.swift
  HeatmapGrid/
    HeatmapGridView.swift
    HeatmapCell.swift
  MoodSlider/
    MoodSliderView.swift
  VoiceInput/
    VoiceInputButton.swift
  PremiumGate/
    PremiumGateView.swift

Extensions/
  Color+Mood.swift
  Date+Helpers.swift
  View+Transitions.swift

Resources/
  Localizable.strings (fr)
  Assets.xcassets
  Fonts/

Widget/
  HeatmapWidget.swift
  MoodWidget.swift
```

### 11.7 Points techniques critiques

- **SwiftData + CloudKit** — `ModelContainer` configuré avec CloudKit uniquement pour premium. Users gratuits en local only.
- **Notifications J+30 / J+90** — Schedulées à la création d'une décision via `UNCalendarNotificationTrigger`. Persistent entre les lancements.
- **Couleurs dynamiques** — `Color+Mood.swift` avec computed property sur `moodScore`. Injecté via `@Environment` dans tous les écrans concernés.
- **StoreKit 2** — `introductoryOffer` pour trial 7 jours sans CB. `Transaction.currentEntitlements` vérifié à chaque lancement.
- **ReformulationService** — `Dictionary<String, [String]>` de mots-clés. Analyse tokenisée du texte, retourne la phrase la plus pertinente.
- **KokoraView** — Component réutilisable avec `enum KokoraExpression`. Animation via `withAnimation` + `offset`. Visuel importé depuis assets.

---

## 12. Décisions produit arrêtées

| Décision                            | Rationale                                                                                   |
| ----------------------------------- | ------------------------------------------------------------------------------------------- |
| Pas d'IA dans le MVP                | L'utilisateur est son propre juge. Plus honnête, zéro coût API, pas de dépendance externe.  |
| Check-in quotidien obligatoire      | Crée l'habitude. Si jour raté → rattrapage le lendemain sans punition.                      |
| Une seule app                       | Journal décisions + accountability + journaling émotionnel dans un seul produit cohérent.   |
| iOS first                           | SwiftUI natif. Android en V2 après validation du concept.                                   |
| Pas de paywall onboarding           | La valeur d'abord, la proposition après.                                                    |
| Essai sans CB                       | StoreKit 2 `introductoryOffer`. Réduit drastiquement la friction d'activation.              |
| CloudKit premium uniquement         | Évite les coûts serveur sur les users gratuits. Local-first pour tous.                      |
| Mascotte Kokora                     | Petite patate orange chibi. Visuels déjà créés et validés.                                  |
| Graphiques humeur gratuits          | C'est le cœur du produit. Les mettre en premium serait contre-productif.                    |
| Pas de sélection couleur onboarding | Dilue le momentum. À mettre dans Settings.                                                  |
| Conversion au moment J+30           | Premier moment de vérité = premier moment émotionnel fort = meilleur moment pour convertir. |

---

## 13. Roadmap MVP

### V1 — MVP

- [ ] Onboarding complet 8 étapes avec Kokora
- [ ] Mood check-in avec slider, activités, émotions, notes, voix, photo
- [ ] Accountability tracker du soir
- [ ] Journal de décisions avec rappels J+30 et J+90
- [ ] Heatmap 90 jours
- [ ] Graphiques d'humeur hebdo et mensuel
- [ ] Lettre au futur moi
- [ ] Rituel du dimanche
- [ ] Feed de citations
- [ ] Défi quotidien
- [ ] Wisdom hebdomadaire
- [ ] Notifications 5 types configurables
- [ ] StoreKit 2 + essai 7 jours sans CB
- [ ] Sign in with Apple
- [ ] KokoraView avec toutes les expressions

### V1.1

- [ ] Widget iOS petit et grand
- [ ] Verrou biométrique Face ID / Touch ID
- [ ] CloudKit sync (premium)
- [ ] Recherche mot-clé dans le journal
- [ ] Thèmes visuels premium

### V2

- [ ] Android
- [ ] Bilan annuel narratif
- [ ] Corrélations avancées
- [ ] Citations personnalisées
- [ ] Patterns de regrets complets
- [ ] IA optionnelle pour validation des raisons d'accountability

---

## 14. Ce qui reste à décider

- **Nom de l'application** — pas encore arrêté. Critères : inventé, 2 syllabes, joyeux et léger, lien avec le projet.
- **Polices exactes** — Crimson Pro validée pour le display, SF Pro pour l'interface. À confirmer dans Xcode avec les tailles exactes.
- **Couleur de fond onboarding** — couleur de la première apparition de Kokora à choisir.
- **Prix exact du premium** — environ 35€/an à valider selon benchmarks App Store français.
- **Phrases Kokora** — minimum 20 formulations par contexte à écrire (reformulations, notifications, insights, moments de vérité).
- **Prompt Midjourney final** — visuels Kokora créés et validés, à exporter aux bons formats pour les assets Xcode.

---

_Document de projet — Version 1.0 — Avril 2026_
