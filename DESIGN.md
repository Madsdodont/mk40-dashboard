---
name: mk40 — Kongerigernes Kamp
description: Live scoretavle som håndsat festens program — editorial monument cream, subtil lækkerhed, eksklusivitets-farve.
colors:
  # Paper palette — light cream surfaces. Token-navne (--ink-*) er retained fra dark-version origin, refactor til --paper-* pending.
  ink-void: "oklch(94% 0.012 60)"    # page background — slight cream
  ink-deep: "oklch(97% 0.008 60)"    # shell background — paper white
  ink-card: "oklch(99% 0.005 60)"    # card surface — brightest
  ink-elevated: "oklch(96% 0.010 60)" # mid surface — tinted paper
  ink-border-soft: "oklch(88% 0.012 60)" # subtle divider
  ink-border: "oklch(75% 0.012 60)"  # visible divider
  # Text scale — warm dark ink. Token-navne (--bone-*) retained, refactor til --text-* pending.
  bone: "oklch(20% 0.014 30)"        # primary text — near-black, warm
  bone-muted: "oklch(40% 0.014 30)"  # secondary text
  bone-dim: "oklch(58% 0.012 30)"    # tertiary text — labels, hints
  # Live red — broadcast pill only
  live-red: "oklch(58% 0.22 25)"
  # Team colors — bandana-mapped, names = bandana identity (locked 2026-06-14), L-calibrated for paper bg contrast
  team-pink: "oklch(58% 0.22 5)"     # Pink bandana — Det Pink Kongerige
  team-navy: "oklch(42% 0.20 258)"   # Navy bandana — Det Mørkeblå Kongerige
  team-grøn: "oklch(50% 0.18 145)"   # Grass green bandana — Det Grønne Kongerige
  team-orange: "oklch(68% 0.18 65)"  # Orange bandana — Det Orange Kongerige
  team-lilla: "oklch(52% 0.18 295)"  # Lilla bandana — Det Lilla Kongerige
  # Gold tokens retired 2026-05-30 — team colors drive everything, leader signaled via own team-color amplified.
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

**Creative North Star: "Festens håndsatte program" — kuratoreret katalog, ikke TV-broadcast.**

Festens scoretavle er ikke et corporate dashboard og ikke en live-broadcast. Den er et omhyggeligt trykt program klædt i paper-cream — monumental i typografi, ceremoniel i rytme, håndsat i detalje. Hold-farverne drives som flag mod paper-canvas; whitespace og soft shadows udstråler eksklusivitet uden at skrige. Editorial monument cream — galleri-katalog filtreret gennem fest-energi.

Systemet afviser eksplicit corporate-dashboard-reflexerne (ingen grids, ingen donut-charts, ingen SaaS-blue-gray), esports-HUD-reflexen (ingen neon, ingen gradient-borders, ingen animerede sparkles) OG den casino-bling-fælde der lurer ved enhver "fest"-event. Mellem disse defaultes til **håndsat program i editorial-register**.

Brand-pivot dokumenteret 2026-05-30: tidligere "OL Olympic Hall Scoreboard" + deep ink + gold-ceremonial-accent retired. Light theme + team-color-driven palette + gold-retired vandt A/B test fordi den lader paletten styre uden at warm ink overdøver.

**Key Characteristics:**
- Paper-canvas (OKLCH cream-tinted neutral hue 60, aldrig pure white)
- 5 hold-farver som named roles, sampled fra fysiske bandanas, L-calibreret for paper-bg
- Editorial serif på holdnavne, display sans på discipliner, mono-tabular på tal
- Ingen gold — leader signaleres via egen team-color amplified (deeper bake, glow, scale-bump)
- Subtile shadows (opacity 0.08-0.14) — paper-on-paper depth, ikke broadcast-flash
- Animation kun ved faktisk score-change (Emil's "rare/first-time → can add delight")
- Multi-screen: TV-broadcast-skala + mobile hand-skala som separate udgaver

## 2. Colors

Paletten styres af de 5 hold-farver. Paper-canvas (cream-tinted neutral) er backdrop, warm-ink er text-foreground, og resten af supporting-paletten holdes stille så hold-identiteten bæres uden konkurrence. Gold retired 2026-05-30.

### Paper canvas (primary surface scale)
- **Ink Void** (oklch(94% 0.012 60)): Page background bag shell — slight cream undertone.
- **Ink Deep** (oklch(97% 0.008 60)): Shell background — paper white.
- **Ink Card** (oklch(99% 0.005 60)): Card surface — brightest paper.
- **Ink Elevated** (oklch(96% 0.010 60)): Mid surface — tinted paper, banner-clock-block.
- **Ink Border Soft** (oklch(88% 0.012 60)): Subtle divider, fine line.
- **Ink Border** (oklch(75% 0.012 60)): Visible divider, sektion-breaks.

*NB:* Token-navne (`--ink-*`) er retained fra dark-version origin. Semantisk er de nu paper-surfaces, ikke ink. Rename til `--paper-*` parkeret som follow-up refactor (mekanisk, holder ikke designet tilbage).

### Tekst (foreground scale — warm ink hue 30)
- **Bone** (oklch(20% 0.014 30)): Primary text — near-black, warm hue 30.
- **Bone Muted** (oklch(40% 0.014 30)): Secondary text — supporting numerics, sub-context.
- **Bone Dim** (oklch(58% 0.012 30)): Tertiary text — labels, hints, placeholder-text.

*NB:* `--bone-*` retained fra dark-origin; semantisk er de nu dark text. Rename til `--text-*` parkeret.

### 5 hold-farver (drive the entire palette)
- **Team Rød** (oklch(58% 0.22 5)): Pink bandana — "Pink Rødder" (rename pending).
- **Team Blå** (oklch(42% 0.20 258)): Navy bandana — Det Blå Imperium.
- **Team Grøn** (oklch(50% 0.18 145)): Grass green bandana — Den Grønne Pagt.
- **Team Gul** (oklch(68% 0.18 65)): Orange/golden bandana — Gyldne Riger.
- **Team Sort/Hvid** (oklch(52% 0.18 295)): Lilla bandana — Den Sorte Cirkel.

L-værdier kalibreret fra bandana-foto til paper-bg-kontrast (dropped 4-10pp fra raw bandana for læsbarhed mod cream).

Hver hold-farve har én rolle: identifikator. Aldrig decoration, aldrig UI-chrome, aldrig accent på andet end holdet selv.

### Live red (broadcast convention only)
- **Live Red** (oklch(58% 0.22 25)): Reserveret til LIVE-pill i banner-clock. Ikke en brand-farve, en broadcast-konvention. Hvid text + hvid dot, hardcoded — uafhængigt af theme-tokens.

### Named Rules
**The Identifier-Only Rule.** Hold-farverne er knyttet til hold og hold alene. Aldrig brugt som UI-accent, button-color, border-decoration, eller mood-tint. Hvis du er fristet til at bruge `team-rød` på noget der ikke er Kongeriget Røde Rødder, hold dig tilbage.

**The No-Gold Rule.** Gold-ceremonial token retired 2026-05-30 efter Mads' diagnose: gold + ink overdøvede de 5 team-farver, gjorde dem til pynt frem for styring. Leader signaleres nu via egen team-color amplified (deeper bake 75% top vs default 50%, team-color glow 50px, border-top 10px vs 6px, total-tal 1.3x scale med team-color text-halo). Ingen gold nogensteder i fest-dashboardet — kun proto-nav (dev-chrome) har en hardcoded amber, ikke en brand-token.

**The Team-Bake Rule.** Hver hold-card har sin team-farve bagt ind i baggrunden (linear-gradient team@50% top → team@18% middle → ink-card bottom). Cards er territorier, ikke ens-paper med stripe-accent.

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

Systemet er **tonally layered + subtle-shadow-elevated**. 3-level shadow-token system (low/medium/high) kombineret med paper-tonal-spread (5 ink-trin). Shadows er warm-tinted (oklch hue 30) og opacity 0.06-0.14 — paper-on-paper-depth, ikke broadcast-flash.

Brand-pivot 2026-05-30: tidligere "The Flat-Tonal Rule" (no box-shadows, depth-via-lightness-only) retired efter Mads' feedback: flade surfaces fungerede ikke i light theme — alle 5 cards "svævede" lige højt uden hierarki, leader-amplification var ikke aflæselig. Subtle shadows + top-edge paper-highlight + bottom team-spill bringer depth uden at skride mod SaaS-shadow eller esports-glow.

### Elevation tokens
- **Shadow Low** (opacity 0.06-0.08): Default cards, panels, banner, disc-strip. Subtle lift fra page-bg.
- **Shadow Medium** (opacity 0.08-0.10): Latest-result panel når has-event. Aktiv-state opløftning.
- **Shadow High** (opacity 0.12-0.14): Leader-card. Stærk lift + team-color ambient glow (50px) som ceremonial signalering.

Per shadow-fundamentals: single light-source fra over → shadows pegér ned. Top-edge får paper-highlight (oklch(100% 0 0 / 0.7)) for "facing-light" effekt. Per elevation-system: max 5-6 levels for at undgå decision paralysis — vi har 3, holder den enkel.

### Named Rules
**The Subtle-Shadow Rule.** Shadows er warm-tinted (oklch hue 30, aldrig pure black) og lav opacity. Tre tokens (low/medium/high) — aldrig hardcode shadow-values i komponenter. Hvis et niveau ikke matcher behovet, justér token-værdien, ikke component-CSS.

**The Light-Catch-From-Above Rule.** Cards, banner, og panels får et 1px paper-highlight top-edge (oklch(100% 0 0 / 0.7)) for at simulere lys fra over. Det er det visuelle anchor for paper-on-paper depth. Aldrig anvendes som bottom-edge eller side-edge — kun top.

**The Team-Color-Glow Rule.** Leader-card får team-color ambient glow (`0 0 50px color-mix(team@25%, transparent)`) som ceremonial signalering. Ikke gold, ikke white — leader's egen farve amplificeret. Glow-radius må aldrig overstige 80px (skrider mod neon).

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
- **Do** brug OKLCH for alle neutrals — paper-tints hue 60 (cream), tekst-tints hue 30 (warm ink). Aldrig `#000` eller `#fff` (undtagelse: paper-highlight `oklch(100% 0 0 / 0.7)` på top-edges + live-pill white).
- **Do** bake team-color ind i card-overflader (linear-gradient team@50% top → team@18% middle → ink-card). Cards er territorier, ikke ens-paper med stripe.
- **Do** signalér leader via egen team-color amplified — deeper bake, team-color glow, tykkere stripe, scale-bump på total-tal. Aldrig via fremmed accent-farve.
- **Do** brug 3-level shadow tokens (low/medium/high) med warm-tint hue 30 + opacity 0.06-0.14. Subtile, paper-on-paper.
- **Do** brug 1px paper-highlight top-edges (`oklch(100% 0 0 / 0.7)`) på cards/panels/banner som light-catch-from-above.
- **Do** animér KUN ved score-change. Score-cell der ikke ændrer værdi får intet motion. (Emil's 100+ times/day rule.)
- **Do** brug Emil's custom ease-out `cubic-bezier(0.23, 1, 0.32, 1)` for alle UI-transitions.
- **Do** respektér `prefers-reduced-motion` — degradér til ren opacity-fade.
- **Do** sampl hold-farver fra bandana-foto, L-kalibrér for paper-bg-kontrast (drop 4-10pp L fra raw bandana).

### Don't:
- **Don't** brug Power BI / corporate dashboard-reflex (Excel-grids, donut charts, navy + light-gray accent). Direkte fra PRODUCT.md anti-references.
- **Don't** brug generisk SaaS-cream + navy reflex (Linear/Notion blue+gray). Også PRODUCT.md anti-reference.
- **Don't** glide ind i Twitch/Esports HUD-territorium: neon-glow, gradient-shadows, animerede sparkles. På risiko-listen i PRODUCT.md.
- **Don't** glide ind i Casino-bling: gold-gradients, hero-metric template, big-bold-loud everywhere. Editorial-personality skal være disciplineret.
- **Don't** glide ind i loud / neon / high-contrast broadcast (NY risiko-line 2026-05-30): light theme + saturerede team-colors kan skride mod neon hvis ikke disciplineret. Soft shadows + generøs whitespace er værnet.
- **Don't** glide ind i Wedding/event-app generisk (NY risiko-line 2026-05-30): Wes Anderson-pastel kan tippe mod softness-without-spine. Monumental + ceremoniel skal forblive rygraden.
- **Don't** brug gold nogensteder i fest-dashboardet — gold tokens retired 2026-05-30. Leader signaleres via egen team-color amplified, ikke gold accent. (Eneste undtagelse: proto-nav dev-chrome har hardcoded amber.)
- **Don't** brug border-left/right >1px som colored stripe på rows eller cells. (Impeccable absolute ban.)
- **Don't** brug gradient-text på title eller numbers. (Impeccable absolute ban.)
- **Don't** brug glassmorphism (backdrop-filter blur som decoration). (Impeccable absolute ban.)
- **Don't** brug hero-metric template på total-row. Stadig en row i tabellen, ikke en separate "hero block". (Impeccable absolute ban.)
- **Don't** animér polling-tick. Den 5-sekunders refresh skal være usynlig. Kun faktiske score-changes får motion.
- **Don't** brug holdfarverne til andet end hold-identifikation. Aldrig button-color, aldrig accent på UI-chrome.
- **Don't** brug `transition: all`. Specificér exact properties (transform, opacity, background-color).
- **Don't** start animation fra `scale(0)`. Start fra `scale(0.95)` + `opacity: 0`. (Emil's "nothing in the real world appears from nothing".)
- **Don't** brug `ease-in` på UI-elementer. Føles sluggish; brug ease-out eller custom.
- **Don't** brug pure-black shadows. Warm-tint hue 30 + low opacity (≤0.14) — per shadow-fundamentals.
- **Don't** lave team-color glow større end 80px radius. Skrider mod neon/esports.
