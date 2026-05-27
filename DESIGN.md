---
name: mk40 — Kongerigernes Kamp
description: Live scoretavle som monument-medaltavle. OL-mood, ikke broadcast-flash.
colors:
  ink-deep: "oklch(18% 0.015 30)"
  ink-elevated: "oklch(22% 0.018 30)"
  ink-border: "oklch(30% 0.020 30)"
  bone: "oklch(94% 0.010 60)"
  bone-muted: "oklch(78% 0.012 60)"
  gold-ceremonial: "oklch(78% 0.16 85)"
  team-rød: "[to be resolved from bandana photo]"
  team-blå: "[to be resolved from bandana photo]"
  team-grøn: "[to be resolved from bandana photo]"
  team-gul: "[to be resolved from bandana photo]"
  team-sortHvid: "[to be resolved from bandana photo]"
typography:
  display:
    fontFamily: "Fraunces, Source Serif Pro, Georgia, serif"
    fontSize: "clamp(2.5rem, 5vw, 4.5rem)"
    fontWeight: 700
    lineHeight: 1.0
    letterSpacing: "-0.02em"
  headline:
    fontFamily: "Fraunces, Source Serif Pro, Georgia, serif"
    fontSize: "1.625rem"
    fontWeight: 600
    lineHeight: 1.1
    letterSpacing: "-0.01em"
  label:
    fontFamily: "Inter Display, Inter, system-ui, sans-serif"
    fontSize: "0.875rem"
    fontWeight: 600
    letterSpacing: "0.08em"
  body:
    fontFamily: "Inter, system-ui, sans-serif"
    fontSize: "1rem"
    fontWeight: 400
    lineHeight: 1.5
  numeric:
    fontFamily: "JetBrains Mono, Berkeley Mono, ui-monospace, monospace"
    fontSize: "2.5rem"
    fontWeight: 600
    fontFeature: '"tnum" 1'
  numeric-total:
    fontFamily: "JetBrains Mono, Berkeley Mono, ui-monospace, monospace"
    fontSize: "3.5rem"
    fontWeight: 700
    fontFeature: '"tnum" 1'
rounded:
  none: "0"
  sm: "2px"
spacing:
  xs: "0.5rem"
  sm: "0.75rem"
  md: "1.25rem"
  lg: "2rem"
  xl: "3rem"
  banner: "4rem"
components:
  scoreboard-row:
    backgroundColor: "{colors.ink-deep}"
    textColor: "{colors.bone}"
    padding: "1.25rem 2rem"
  scoreboard-header-row:
    backgroundColor: "{colors.ink-elevated}"
    textColor: "{colors.bone-muted}"
    typography: "{typography.label}"
    padding: "1rem 2rem"
  scoreboard-total-row:
    backgroundColor: "{colors.ink-elevated}"
    textColor: "{colors.gold-ceremonial}"
    typography: "{typography.numeric-total}"
    padding: "1.5rem 2rem"
---

# Design System: mk40 — Kongerigernes Kamp

## 1. Overview

**Creative North Star: "The Olympic Hall Scoreboard"**

Festens scoretavle er ikke et corporate dashboard. Den er en monumental medaltavle bygget til et lørdagsritualt klædt i deep ink — ceremoniel uden at være højtidelig, eksplosiv kun i score-change-øjeblikket. OL-stadion-storsskærm filtreret gennem editorial-ro: tabulær præcision på data, monumental typografi på navne, deep ink-canvas der lader hold-farverne brænde frem som flag.

Systemet afviser eksplicit corporate-dashboard-reflexerne: ingen grids, ingen donut-charts, ingen subtle SaaS-shadows. Det afviser også esports-HUD-reflexen: ingen glow, ingen gradient-borders, ingen animerede sparkles. Mellem disse to defaultes til **fest-broadcast i ceremonial-register**.

**Key Characteristics:**
- Deep ink-canvas (OKLCH-tinted neutral, mod cream-burgundy)
- 5 hold-farver som named roles, sampled fra fysiske bandanas
- Editorial serif på holdnavne, display sans på discipliner, mono-tabular på tal
- Gold ceremonial-accent reserveret total-row leader
- Animation kun ved faktisk score-change (Emil's "rare/first-time → can add delight")
- Multi-screen: TV-broadcast-skala + mobile hand-skala som separate udgaver

## 2. Colors

Paletten er fem mættede hold-identifikatorer mod en deep ink-canvas tintet mod burgundy. Gold er reserveret total-row-leader; resten af interfacet er stille.

### Primary
- **Ink Deep** (oklch(18% 0.015 30)): Canvas. Hele scoretavlens baggrund. Tintet mod warm/burgundy, ikke pure black — Emil's regel om aldrig `#000`. På TV mod variabelt ambient lys forbliver dette neutralt-dybt uden at virke vasket.
- **Ink Elevated** (oklch(22% 0.018 30)): Header-row + total-row surface. Tydeligt opdriftet uden borders.
- **Ink Border** (oklch(30% 0.020 30)): Skille-linjer mellem rows, kun hvor nødvendigt.

### Secondary
- **Gold Ceremonial** (oklch(78% 0.16 85)): Total-row text. Reserveret rene placeringer — den ene farve der bryder out af paletten signalerer leader. Brugen er ≤5% af surfacen.

### Tertiary (de 5 hold som named roles)
- **Team Rød** ([HEX sampled fra bandana]): Kongeriget Røde Rødder.
- **Team Blå** ([HEX sampled]): Det Blå Imperium.
- **Team Grøn** ([HEX sampled]): Den Grønne Pagt.
- **Team Gul** ([HEX sampled]): Gyldne Riger.
- **Team Sort/Hvid** ([HEX sampled]): Den Sorte Cirkel.

Hver hold-farve har én rolle: identifikator. Aldrig decoration, aldrig UI-chrome, aldrig accent på andet end holdet selv.

### Neutral
- **Bone** (oklch(94% 0.010 60)): Foreground text mod ink-canvas. Cream-tintet hvid, aldrig pure white.
- **Bone Muted** (oklch(78% 0.012 60)): Label-tekst, header-row text. Stille hierarchy under bone.

### Named Rules
**The Identifier-Only Rule.** Hold-farverne er knyttet til hold og hold alene. Aldrig brugt som UI-accent, button-color, border-decoration, eller mood-tint. Hvis du er fristet til at bruge `team-rød` på noget der ikke er Kongeriget Røde Rødder, hold dig tilbage.

**The Gold Reserve Rule.** Gold ceremonial er total-row-text only. Aldrig button, aldrig border, aldrig accent. Dens sjældenhed er pointen.

## 3. Typography

**Display Font:** Fraunces (faldback Source Serif Pro → Georgia)
**Body/Label Font:** Inter Display + Inter (faldback system-ui)
**Numeric Font:** JetBrains Mono (faldback Berkeley Mono → ui-monospace)

**Character:** Editorial-monumental-serif på navne (hvert hold som titulært væsen), uppercase display-sans på labels (broadcast-headers, ikke prose), og tabular-mono på tal (præcis aflæsning fra distance). Tre familier hver med klart rolle-rationale — ikke decorativ-mix.

### Hierarchy
- **Display** (700, clamp(2.5rem, 5vw, 4.5rem), 1.0): Sidetitel "mk40 — Kongerigernes Kamp". Én forekomst i page-header.
- **Headline** (600, 1.625rem, 1.1): Holdnavne i scoretavle-header. "KONGERIGET RØDE RØDDER" osv. Italics-variant kan bruges til total-row.
- **Label** (Inter Display, 600, 0.875rem, letter-spacing 0.08em, UPPERCASE): Disciplin-labels ("BOWLING", "DART"), header-meta ("DISCIPLIN"). Tracking åbnet for broadcast-feel.
- **Body** (Inter, 400, 1rem, 1.5): Footer, status-bar, edge-cases. Ikke i scoretavle-celler.
- **Numeric** (JetBrains Mono, 600, 2.5rem, tnum): Scoreceller. Mono så kolonner aligner; tabular-figures så tal med samme antal cifre matcher horizontally.
- **Numeric Total** (JetBrains Mono, 700, 3.5rem, tnum): Total-row. Større + tungere + gold-coloreret.

### Named Rules
**The Display-Sans-on-Labels Rule.** Inter Display med 0.08em tracking + UPPERCASE er broadcast-default. Disciplin-navne, header-cells, footer-meta — alt der ikke er prose, headline, eller numerisk falder herind. Aldrig casual case eller variable tracking.

**The Tabular-Figures Rule.** Alle scoretal og total-tal har `font-feature-settings: "tnum" 1`. 91 + 12 må ikke kollidere fordi 1'eren er smallere. Tabulær præcision er ikke-forhandelbar.

## 4. Elevation

Systemet er **tonally layered, ikke shadow-elevated**. Ingen box-shadows. Ingen drop-shadows. Ingen glow. Depth opnås via subtile lightness-skift i ink-paletten (deep → elevated → border = 3 OKLCH-trin).

Dette er en bevidst rejection af både SaaS-shadow-default og esports-glow-reflex. På TV-distance forsvinder shadow-subtilitet alligevel — tonal-layering læses fra 8 meter, shadows gør ikke.

### Named Rules
**The Flat-Tonal Rule.** Surfaces er flade. Hierarki læses af baggrundsfarvens lightness-trin, ikke af shadow eller stroke. Hvis du er fristet til at tilføje en shadow for "depth" — gør lightness-trinnet større i stedet.

## 5. Components

### Scoreboard Table
- **Shape:** Ingen border-radius på selve tabellen. Lige kanter, monument-kant. (Skeleton-versionens 12px radius er rejected — det føles SaaS, ikke OL.)
- **Header row:** Ink Elevated baggrund, Bone Muted text, label-typography, UPPERCASE, tracking 0.08em. Holdnavne her: Headline-typography (Fraunces 1.625rem 600), hver med data-team-color på text-farve på en lille pre-pillar (4px width inline før navnet) — IKKE en border-left.
- **Body cells:** Ink Deep baggrund, Bone text, Numeric typography. Tabular figures. Pure tal, ingen separators, "—" hvis tom.
- **Discipline label cells:** Venstre-justeret, Label typography (Inter Display UPPERCASE), Bone Muted. Lille `/max_points` suffix i samme typography men 0.85x scale.
- **Total row:** Ink Elevated baggrund, Gold Ceremonial text, Numeric Total typography, lidt mere padding (1.5rem vs 1.25rem) end body-rows.

### Score Cell — Change State (the delight moment)
Default: ingen animation. Polling refresher tal silently.
Change detected (cell-value differs fra forrige render):
- Scale: 0.95 → 1.0 over 240ms, custom ease-out `cubic-bezier(0.23, 1, 0.32, 1)` (Emil's strong ease-out)
- Opacity: 0 → 1 over 240ms (samme curve)
- Holdfarve-pulse: subtle background-color 240ms → fade tilbage til Ink Deep over 600ms
- Total-row counter: count-up over 600ms (mono-font aligned)
- `prefers-reduced-motion`: degraderer til ren opacity-fade, ingen scale, ingen pulse

### Page Header (Title bar)
- **Shape:** Padding 1.5rem 2rem, Ink Deep, full-width banner.
- **Typography:** Display font på title, Bone text. Bone Muted-tone på "Opdateret HH:MM:SS" til højre.
- **Border:** 1px solid Ink Border bottom. IKKE side-stripe (Impeccable absolute ban).

### Footer
- **Shape:** Padding 1rem 2rem, Ink Deep, full-width banner.
- **Typography:** Body, 0.875rem, Bone Muted.
- **Connection dot:** Gold ceremonial når OK, Team Rød når error. Lille (6px circle), ingen pulse.

### Named Rules
**The No-Border-Left Rule.** Aldrig `border-left` med >1px tykkelse som accent. Holdfarverne markeres via inline pillar (full-height div, 4px width) eller text-color, aldrig som side-stripe på rows eller cells. (Direkte cite fra Impeccable absolute bans.)

## 6. Do's and Don'ts

### Do:
- **Do** brug Fraunces (eller specified faldback) på holdnavne. Editorial serif er den valgte voice.
- **Do** brug JetBrains Mono med `font-feature-settings: "tnum" 1` på alle tal. Tabular figures er ikke-forhandelbar for kolonne-alignment.
- **Do** brug OKLCH for alle neutrals med chroma 0.010-0.020 tintet mod brand-hue (~30°). Aldrig `#000` eller `#fff`.
- **Do** animér KUN ved score-change. Score-cell der ikke ændrer værdi får intet motion. (Emil's 100+ times/day rule.)
- **Do** brug Emil's custom ease-out `cubic-bezier(0.23, 1, 0.32, 1)` for alle UI-transitions.
- **Do** respektér `prefers-reduced-motion` — degradér til ren opacity-fade.
- **Do** sampl hold-farver fra bandana-foto. Visuel kobling fest↔dashboard er en taste-detail.

### Don't:
- **Don't** brug Power BI / corporate dashboard-reflex (Excel-grids, donut charts, navy + light-gray accent). Direkte fra PRODUCT.md anti-references.
- **Don't** brug generisk SaaS-cream + navy reflex (Linear/Notion blue+gray). Også PRODUCT.md anti-reference.
- **Don't** glide ind i Twitch/Esports HUD-territorium: neon-glow, gradient-shadows, animerede sparkles. På risiko-listen i PRODUCT.md.
- **Don't** glide ind i Casino-bling: gold-gradients, hero-metric template, big-bold-loud everywhere. Stadium-personality skal være disciplineret.
- **Don't** brug border-left/right >1px som colored stripe på rows eller cells. (Impeccable absolute ban.)
- **Don't** brug gradient-text på title eller numbers. (Impeccable absolute ban.)
- **Don't** brug glassmorphism (backdrop-filter blur som decoration). (Impeccable absolute ban.)
- **Don't** brug hero-metric template på total-row. Stadig en row i tabellen, ikke en separate "hero block". (Impeccable absolute ban.)
- **Don't** animér polling-tick. Den 5-sekunders refresh skal være usynlig. Kun faktiske score-changes får motion.
- **Don't** brug holdfarverne til andet end hold-identifikation. Aldrig button-color, aldrig accent på UI-chrome.
- **Don't** brug `transition: all`. Specificér exact properties (transform, opacity, background-color).
- **Don't** start animation fra `scale(0)`. Start fra `scale(0.95)` + `opacity: 0`. (Emil's "nothing in the real world appears from nothing".)
- **Don't** brug `ease-in` på UI-elementer. Føles sluggish; brug ease-out eller custom.
