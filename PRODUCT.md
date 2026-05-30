# Product

## Register

product

## Users

**Primært:** 28 fest-gæster + 5 holdkaptajner + Mads (MC) + AC (taste-canary). Sekundært: gæster på egne telefoner via QR (input + observation-strøm).

**Kontekst:** Lørdag aften 2026-06-27, festlokale. Multi-screen setup — TV (55"+, 3-8m visning) som central scoretavle parallelt med gæste-mobiler. Variabelt ambient lys gennem aftenen. Gæster i social-flow, ikke fokuserede.

**Job:** (a) Glance og se hvem leder. (b) Bemærke når en disciplin afgøres. (c) Blive grebet af AI-callouts ved score-change. (d) Føle sig en del af "Kongerigernes Kamp" som visuelt event, ikke bare en konkurrence.

## Product Purpose

Live scoretavle der gør konkurrencen synlig, kommenterbar og ceremoniel. End-to-end Claude-built artifact der lukker to learning-milestones (autonomous workflow + API-powered artifact). Festens visuelle signatur.

**Success:** AC reagerer uforklaret positivt. Gæster fortæller om scoretavlen efter festen uden at være blevet bedt om at huske den.

## Brand Personality

**Tre ord:** Monumental, ceremoniel, håndsat.

**Voice:** Subtil lækkerhed. Hand-set typografi, generøs whitespace, soft shadows, og farver der udstråler eksklusivitet — som en kuratoreret katalog eller et nøje sat trykt program, ikke en TV-broadcast. Hold som nationer. Tunge typografier, tabulær præcision, soft contrast — *men* score-change-øjeblikket må have delight (subtil pulse, ingen flash).

**Emotional goal:** Når en gæst kigger op på scoretavlen, skal de føle de står foran et omhyggeligt trykt festens program — ikke et corporate dashboard, ikke en live-broadcast.

## Anti-references

- **Power BI / corporate dashboard** — Excel-grid-vibe, donut-charts, navy-blue-and-light-gray accent. Reflex der dræber 90% af dashboards.
- **Generisk SaaS (Linear/Notion blue+gray)** — den trygge SaaS-cream + navy-reflex. Kompetent intetsigende.
- **Twitch/Esports HUD** — neon-glow, gradient-shadow på holdkort, animerede sparkles. Editorial-lane skal beskytte mod at glide derhen.
- **Casino-bling** — gold-gradients, hero-metric template, big-bold-loud. Subtil lækkerhed kan tippe der hvis disciplinen smutter.
- **Loud / neon / high-contrast broadcast (på risiko-liste)** — light theme + saturerede team-colors kan skride mod neon hvis ikke disciplineret. Soft shadows og generøs whitespace er værnet.
- **Wedding/event-app generisk (på risiko-liste)** — Wes Anderson-pastel kan tippe mod softness-without-spine. Monumental + ceremoniel skal forblive rygraden, ikke kun "pænt og rosa".

## Design Principles

1. **Læsbar fra tværs af rummet, før smuk fra to meters afstand.** TV-distance (3-8m) er forced constraint. Type-størrelse, tonal kontrast og bevidst whitespace er ikke-forhandelbare — selv subtil lækkerhed skal kunne læses fra 8m.
2. **Polling skal være stille; score-change må gerne være delight.** Default-states har nul animation. Det er det øjeblik en celle faktisk *ændrer sig* der får motion — og kun da. (Emil's "100+ times/day → no animation" + "Rare/first-time → can add delight".)
3. **Hold-farverne er identifikatorer, ikke decoration.** Ingen brug af holdfarverne som accents på UI-chrome. De er knyttet til hold og hold alene — så øjet finder dem uden læsning.
4. **Multi-screen er to udgaver, ikke én responsiv.** TV-version er broadcast-skala (læses fra 8m). Mobile-version er hand-skala (læses fra 30cm). Forced responsive blur skal undgås.
5. **Beauty is leverage** (Emil). Festens dashboard er en undertudt taste-investering — gæster fortæller om det fordi det er anderledes godt, ikke fordi det er funktionelt.

## Accessibility & Inclusion

- **WCAG:** AA-contrast som baseline. Score-text mod baggrund: min 7:1 (AAA — fordi TV-distance + variable lys).
- **prefers-reduced-motion:** Score-change-animation degraderer til ren fade (opacity-only). Ingen scale, ingen translate.
- **Color-blindness:** Hold-identifikation må ikke afhænge kun af farve. Hold-navn altid synligt ved score-cellen. Holdfarven er ekstra, ikke primær.
- **Lyd-cues:** Ingen lyd på TV-version (festen har egen musik). Mobile-version kan have valgfri haptic ved input.
