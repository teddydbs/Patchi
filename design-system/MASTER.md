# Design System Kokora — MASTER

> Source of truth pour tout l'UI de Kokora. Chaque écran doit respecter ces règles sauf override dans `pages/`.

## Style : Claymorphism Mobile Organique

Style mascotte-led, playful, journaling émotionnel. Inspiré claymorphism mais adapté avec l'identité orange Kokora et les couleurs vives de mood.

### Principes

1. **Jamais blanc pur ni noir pur** — fonds toujours teintés par le contexte émotionnel
2. **Formes organiques** — blobs, pills, capsules — pas de rectangles rigides
3. **Hiérarchie par la taille** — gros chiffres, gros emojis, titres imposants
4. **Profondeur clay** — ombres multi-layer (inner + outer), pas de flat shadow
5. **Spring physics** — animations naturelles, interruptibles, 150-300ms
6. **Haptic partout** — feedback tactile sur chaque action clé
7. **Kokora omniprésent** — la mascotte guide, réagit, accompagne

---

## Couleurs

### Tokens sémantiques

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `kokoraOrange` | `#FF9933` | `#FF9933` | CTA principal, mascotte, accents |
| `accentPurple` | `#7C3AED` | `#A78BFA` | Insights, stats, premium |
| `accentAmber` | `#D97706` | `#F59E0B` | Streaks, badges, warnings |
| `success` | `#059669` | `#10B981` | Confirmations, positif |
| `destructive` | `#DC2626` | `#EF4444` | Suppression, danger |
| `background` | `#FFF8F0` (crème chaud) | `#1A1614` (brun nuit) | Fond principal |
| `cardBg` | `rgba(255,255,255,0.7)` | `rgba(255,255,255,0.08)` | Cards glass-clay |
| `textPrimary` | `#1E1A16` | `#F5F0EB` | Corps de texte |
| `textSecondary` | `#64748B` | `#94A3B8` | Labels, hints |
| `border` | `#F0E6D9` | `#2D2520` | Séparateurs, contours |

### Couleurs mood (inchangées)

| Score | Couleur | Hex approx |
|-------|---------|------------|
| 5 | Jaune soleil vif | `#FFD926` |
| 4 | Vert émeraude franc | `#1ABF80` |
| 3 | Beige chaud | `#EBD9B3` |
| 2 | Violet doux | `#8C59B3` |
| 1 | Bleu nuit profond | `#1A1F59` |
| Stress | Orange vif | `#FF8C26` |
| Colère | Rouge corail | `#F25959` |

---

## Typographie

| Rôle | Police | Poids | Usage |
|------|--------|-------|-------|
| Émotionnel | **Crimson Pro Italic** | 400-600 | Titres, questions Kokora, citations, reformulations |
| Fonctionnel | **SF Pro** (système) | 400-700 | Labels, données, interface, boutons |

### Échelle

| Style | Taille | Line Height |
|-------|--------|-------------|
| Hero | 48pt | 52pt |
| Section Title | 32pt | 38pt |
| Card Title | 22pt | 28pt |
| Body | 17pt | 24pt |
| Caption | 13pt | 18pt |

---

## Formes & Rayons

| Élément | Border Radius |
|---------|---------------|
| Conteneur extérieur / écran | 40-50pt |
| Cards | 32pt |
| Boutons | 20pt (pill) |
| Chips / tags | 16pt |
| Inputs | 16pt |
| Avatar / icône ronde | 50% |

---

## Ombres (Clay Stack)

```
// Outer shadow (profondeur)
.shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 8)
.shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)

// Inner highlight (clay effect) — via overlay
.overlay(
    RoundedRectangle(cornerRadius: 32)
        .stroke(Color.white.opacity(0.3), lineWidth: 1)
)
```

---

## Animations

| Type | Durée | Courbe |
|------|-------|--------|
| Micro-interaction | 150-200ms | `.spring(response: 0.3, dampingFraction: 0.7)` |
| Transition écran | 300-400ms | `.spring(response: 0.5, dampingFraction: 0.85)` |
| Press feedback | immédiat | `scaleEffect(0.92)` + spring |
| Blob drift | 8-12s | `linear` loop |
| Exit | 60-70% de l'enter | même courbe |

### Règles

- Toute animation doit être interruptible
- Respecter `AccessibilityReduceMotion`
- Spring physics > cubic bezier
- Max 2 éléments animés simultanément par vue

---

## Composants de base

### Bouton principal (Pill)
- Hauteur : 56pt
- borderRadius : 20pt
- Gradient : kokoraOrange → kokoraOrange.opacity(0.85)
- Texte : SF Pro Semibold 17pt, couleur sur fond orange
- Press : scale 0.92, spring, haptic `.light`
- Ombre clay standard

### Card
- borderRadius : 32pt
- Background : cardBg (glass-clay)
- Padding : 20pt
- Ombre clay stack
- Inner stroke blanc 0.3

### Chip / Filter Pill
- borderRadius : 16pt
- Hauteur : 36pt
- Padding horizontal : 16pt
- Active : fond kokoraOrange, texte blanc
- Inactive : fond cardBg, texte textSecondary

### Blob Background
- Formes : Circle/Ellipse avec blur 60-80
- Opacité : 0.15-0.25
- Animation : drift ±20px sur 8-12s, loop infini
- Couleurs : mood du contexte actuel

---

## Checklist par écran

- [ ] Fond teinté (jamais blanc pur ni noir pur)
- [ ] Cards borderRadius 32, ombre clay stack
- [ ] Boutons pill borderRadius 20, scale press 0.92
- [ ] Blobs organiques en background
- [ ] Hiérarchie par la taille
- [ ] Haptic sur actions clés
- [ ] Dark mode testé
- [ ] Touch targets >= 44pt
- [ ] Crimson Pro pour émotionnel, SF Pro pour fonctionnel
- [ ] SF Symbols pour les icônes (pas d'emoji structurel)
- [ ] Animations spring, interruptibles
- [ ] Safe areas respectées
- [ ] État vide avec Kokora qui parle
