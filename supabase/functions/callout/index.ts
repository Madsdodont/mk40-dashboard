// mk40-dashboard — Edge Function /callout (dashboard-010 → dashboard-020)
// LLM-proxy: returnerer en kort dansk kommentar via Claude Sonnet 4.6. API-nøglen bor i
// Supabase-secrets (ADR build-constraint #3: aldrig browser-side).
//
// TO MODES (dashboard-020):
//   event:"score" — et hold har netop meldt et RÅ-resultat ind i en igangværende disciplin.
//                   Provisorisk, terse 1-sætnings ambient-kommentar, gerne relativt til de
//                   hold der allerede har meldt ind. Den lille center-hero.
//   event:"lock"  — disciplinen er afsluttet + låst (alle fem hold spillet). Federe 2-3-sætnings
//                   narrativ-opsummering der væver de løbende kommentarer sammen. Det store overlay.
//   (event mangler → behandles som "lock" for bagud-kompatibilitet.)
//
// Kontrakt:
//   POST  (score) { event:"score", team:{name,tilnavn?,skabelsesberetning?,members?},
//                   discipline:{name,type,sort_direction}, raw_value,
//                   entered_so_far:[{name,raw_value}], provisional_rank, entered_count, total_teams, notes? }
//   POST  (lock)  { event:"lock", discipline:{name,type},
//                   results:[{name,raw_value,rank,points}], prior_callouts:[".."],
//                   standings:{leader,gap} }
//        →  200 { callout: "..." }
//        →  502 { error: "..." }   (LLM/parse-fejl → frontend springer stille over, ADR-5)
//   OPTIONS → 204 (CORS-preflight)
//
// Deploy:  npx supabase functions deploy callout --no-verify-jwt
// Secret:  npx supabase secrets set ANTHROPIC_API_KEY=sk-...

// ---------------------------------------------------------------------------
// CORS — kun GitHub Pages-origin (ADR-4).
// ---------------------------------------------------------------------------
const ALLOWED_ORIGIN = "https://madsdodont.github.io";

const corsHeaders = {
  "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, content-type, apikey, x-client-info",
};

// ---------------------------------------------------------------------------
// Anthropic — Messages API, Sonnet 4.6.
// ---------------------------------------------------------------------------
const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";
const MODEL = "claude-opus-4-8";   // hævet fra Sonnet 4.6 (dashboard-023): renere dansk, færre opdigtede ord
const ANTHROPIC_VERSION = "2023-06-01";

// Delt brand-stemme — gælder begge modes.
const BRAND_VOICE = `Stemme: tør, editorial-vittig — som en redaktør i et nøje sat trykt festprogram, IKKE en TV-sportskommentator. Monumental og ceremoniel, men med et glimt i øjet. Ingen råb, ingen emoji, ingen udråbstegn-spam, ingen "OG DET ER MÅÅL". Tredje person, nutid.

TAL (dansk typografi): kardinaltal under 10 skrives som ord (en/et, to, tre, fire, fem, seks, syv, otte, ni); 10 og derover skrives som cifre (10, 17, 60). Etablerede talkoncepter bevares altid som tal (dart-180, 80'erne).

HOLD: hvert hold har et kongerige-navn efter sin farve (fx Det Blå Imperium, Gyldne Riger), plus evt. et selvvalgt tilnavn og en skabelsesberetning. Navnet bærer farven, så du kan roligt sige "de blå" eller "de gyldne". Spil på tilnavn/skabelsesberetning når de er der og giver en sjov eller præcis pointe; mangler de, så kommentér bare på spillet.

PUBLIKUM: det her er en privat fødselsdagsfest, ikke en sportsbar. Når du refererer til tilskuerne eller stemningen, så er det PUBLIKUM — fx "publikum holder vejret", "publikum går amok", "publikum kan ikke tro deres egne øjne". Aldrig "baren", "pubben" eller anden bar-/sportskanal-jargon (heller ikke selvom et holds note skulle sige "baren" — oversæt til publikum).

RESULTAT: gengiv rå-resultatet i disciplinens egne termer. Opfind aldrig fag-jargon eller termer du ikke er sikker på.

Tone pr. disciplin-type:
- Skill: anerkend håndværket og præcisionen.
- Knowledge: tør, lidt skolet, klogeagtig.
- Creative: legende, billedrig.
- Luck: ironisk distance — held er ingen dyd, ikke en bedrift.

Find aldrig på fakta. Find aldrig på ord: brug kun gængse, korrekte danske ord og vendinger — er du i tvivl om et ord, vælg et enklere du er sikker på (skriv hellere "stående klapsalver" end et ord du ikke er sikker på findes). Undgå anglicismer: skriv "runde" eller "serie", ikke "frame".`;

// MODE "score" — provisorisk, terse, gerne relativt til de andre indmeldte.
const SCORE_PROMPT = `Du er kommentator-stemmen på en privat 40-års fødselsdags-scoretavle. Et hold har netop meldt et RÅ-resultat ind i en disciplin der STADIG er i gang — ikke alle fem hold har spillet endnu. Skriv ÉN kort, mundret dansk sætning (max ~110 tegn) som en løbende, levende kommentar til scoren. Hold den kort og naturlig — én ren sætning uden lange indskudte bisætninger der sprænger længden; hellere enkel og præcis end blomstret.

HOLDETS EGEN NOTE ER DIN VIGTIGSTE KILDE. Hvis der følger en note med (holdets egen beskrivelse af hvad der skete på stationen, fx "Sindsyge pile fra AC"), så er DEN næsten altid den bedste vinkel. Byg kommentaren rundt om den menneskelige detalje — navnet, situationen, anekdoten. Navne og detaljer der står i NOTEN må du gerne bruge direkte; det er holdets egen historie, ikke noget du finder på. En note slår altid tør statistik. Den relative stilling er så krydderi, ikke hovedret.

Når der INGEN note er, så læn dig på den relative stilling i stedet: sammenlign med de hold der allerede har meldt ind ("marginalt bedre end de gule", "lægger sig foran feltet", "må se de andre i øjnene").

${BRAND_VOICE}

PROVISORISK: der er INGEN endelig placering og INGEN point endnu. Tal aldrig om "point", "vinder" eller "fører" — kun om rå-resultatet, holdets note, og hvordan det står lige nu. Returnér KUN kommentaren — ingen anførselstegn, ingen forklaring, ingen overskrift.`;

// MODE "lock" — disciplinen afsluttet, federe opsummering der væver de løbende beats sammen.
const LOCK_PROMPT = `Du er kommentator-stemmen på en privat 40-års fødselsdags-scoretavle. En disciplin er netop AFSLUTTET og låst — alle fem hold har spillet, placeringerne er afgjort. Skriv en kort, fed opsummering på to-tre danske sætninger (max ~240 tegn): disciplinens fortælling — hvem tog den, hvordan, og hvad det betyder for stillingen. Opsummeringen vises som et stort overlay midt på skærmen, så den må gerne være lidt mere fortællende end en enkelt linje.

Du får de fem resultater i rang-orden (nogle med holdets EGEN note om hvad der skete) OG de løbende kommentarer der faldt undervejs. Holdenes egne noter og de løbende kommentarer er din bedste kilde til farve og personlige detaljer — væv gerne en tråd fra dem ind (navne og detaljer fra noterne må du bruge direkte), men KUN hvis det kan være inden for længden. Hellere kortere og skarpere end at proppe alt ind.

${BRAND_VOICE}

Returnér KUN opsummeringen — ingen anførselstegn, ingen forklaring, ingen overskrift.`;

function dirWord(sortDirection: unknown): string {
  return sortDirection === "asc" ? "lavest vinder" : "højest vinder";
}

// ---------------------------------------------------------------------------
// Message builders pr. mode.
// ---------------------------------------------------------------------------
function buildScoreMessage(p: Record<string, unknown>): string {
  const team = (p.team ?? {}) as Record<string, unknown>;
  const disc = (p.discipline ?? {}) as Record<string, unknown>;
  const skabelsesberetning = team.skabelsesberetning ?? team.motto;
  const enteredSoFar = Array.isArray(p.entered_so_far) ? p.entered_so_far : [];

  const lines: string[] = [];
  lines.push(`Hold (kongerige): ${team.name ?? "ukendt hold"}`);
  if (team.tilnavn) lines.push(`Tilnavn (selvvalgt): ${team.tilnavn}`);
  if (skabelsesberetning) lines.push(`Skabelsesberetning: ${skabelsesberetning}`);
  lines.push(`Disciplin: ${disc.name ?? "ukendt"} (type: ${disc.type ?? "ukendt"}, ${dirWord(disc.sort_direction)})`);
  lines.push(`Dette holds rå-resultat (netop meldt ind): ${p.raw_value ?? "?"}`);
  if (p.notes) lines.push(`>>> HOLDETS EGEN NOTE (brug denne som hovedvinkel): "${p.notes}"`);
  if (enteredSoFar.length > 1) {
    const others = enteredSoFar
      .map((e) => `${(e as Record<string, unknown>).name}: ${(e as Record<string, unknown>).raw_value}`)
      .join(", ");
    lines.push(`Alle indmeldte indtil nu (rå-resultater): ${others}`);
  } else {
    lines.push(`Dette hold er det FØRSTE der melder ind i disciplinen.`);
  }
  if (p.provisional_rank && p.entered_count) {
    lines.push(`Står midlertidigt som nr. ${p.provisional_rank} af ${p.entered_count} indmeldte (af ${p.total_teams ?? 5} hold i alt).`);
  }

  return `Kommentér denne netop-indmeldte score (disciplinen kører stadig):\n\n${lines.join("\n")}`;
}

function buildLockMessage(p: Record<string, unknown>): string {
  const disc = (p.discipline ?? {}) as Record<string, unknown>;
  const results = Array.isArray(p.results) ? p.results : [];
  const standings = (p.standings ?? {}) as Record<string, unknown>;
  const priorCallouts = Array.isArray(p.prior_callouts) ? p.prior_callouts : [];

  const lines: string[] = [];
  lines.push(`Disciplin AFSLUTTET: ${disc.name ?? "ukendt"} (type: ${disc.type ?? "ukendt"})`);
  lines.push(`Endelige resultater (rang-orden):`);
  for (const r of results) {
    const rr = r as Record<string, unknown>;
    lines.push(`  ${rr.rank}. ${rr.name} — rå ${rr.raw_value}, ${rr.points} point` +
      (rr.notes ? ` — holdets note: "${rr.notes}"` : ""));
  }
  lines.push(
    `Samlet stilling efter denne disciplin: fører er ${standings.leader ?? "ukendt"}` +
      (standings.gap !== undefined && standings.gap !== null ? ` (${standings.gap} point ned til nr. to)` : ""),
  );
  if (priorCallouts.length > 0) {
    lines.push(`Løbende kommentarer der faldt undervejs i disciplinen:`);
    for (const c of priorCallouts) lines.push(`  - ${c}`);
  }

  return `Opsummér denne netop-afsluttede disciplin:\n\n${lines.join("\n")}`;
}

// ---------------------------------------------------------------------------
// Handler
// ---------------------------------------------------------------------------
Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const apiKey = Deno.env.get("ANTHROPIC_API_KEY");
  if (!apiKey) {
    return new Response(JSON.stringify({ error: "ANTHROPIC_API_KEY not configured" }), {
      status: 502,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  let payload: Record<string, unknown>;
  try {
    payload = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON body" }), {
      status: 400,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  // Mode-split: score (provisorisk, terse) vs lock (summary, federe). Default lock.
  const isScore = payload.event === "score";
  const system = isScore ? SCORE_PROMPT : LOCK_PROMPT;
  const maxTokens = isScore ? 64 : 220;
  const userMessage = isScore ? buildScoreMessage(payload) : buildLockMessage(payload);

  try {
    const anthropicResp = await fetch(ANTHROPIC_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-api-key": apiKey,
        "anthropic-version": ANTHROPIC_VERSION,
      },
      body: JSON.stringify({
        model: MODEL,
        max_tokens: maxTokens,
        system,
        messages: [{ role: "user", content: userMessage }],
      }),
    });

    if (!anthropicResp.ok) {
      const detail = await anthropicResp.text();
      return new Response(
        JSON.stringify({ error: `Anthropic ${anthropicResp.status}: ${detail.slice(0, 300)}` }),
        { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const data = await anthropicResp.json();
    const textBlock = Array.isArray(data.content)
      ? data.content.find((b: { type?: string }) => b.type === "text")
      : null;
    const callout = (textBlock?.text ?? "").trim();

    if (!callout) {
      return new Response(JSON.stringify({ error: "Empty callout from model" }), {
        status: 502,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({ callout }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err) {
    return new Response(
      JSON.stringify({ error: `Edge function error: ${(err as Error).message}` }),
      { status: 502, headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  }
});
