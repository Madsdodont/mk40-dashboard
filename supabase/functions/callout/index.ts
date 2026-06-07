// mk40-dashboard — Edge Function /callout (dashboard-010)
// LLM-proxy: modtager en netop-låst FactScore-kontekst, returnerer en kort dansk
// kommentar via Claude Sonnet 4.6. API-nøglen bor i Supabase-secrets (ADR build-constraint #3:
// aldrig browser-side). Frontend-wiring + scoreændring-trigger er dashboard-011, IKKE her.
//
// Kontrakt:
//   POST    { team:{name, tilnavn?, skabelsesberetning?, members?}, discipline:{name,type},
//             points, rank, raw_value?, notes?, standings:{leader,gap} }
//   (motto accepteres som bagud-kompatibelt alias for skabelsesberetning)
//        →  200 { callout: "..." }
//        →  502 { error: "..." }   (LLM/parse-fejl → 011 springer callout stille over, ADR-5)
//   OPTIONS → 204 (CORS-preflight)
//
// Deploy:  npx supabase functions deploy callout
// Secret:  npx supabase secrets set ANTHROPIC_API_KEY=sk-...

// ---------------------------------------------------------------------------
// CORS — kun GitHub Pages-origin (ADR-4). localhost kan tilføjes for 011-lokal-dev.
// ---------------------------------------------------------------------------
const ALLOWED_ORIGIN = "https://madsdodont.github.io";

const corsHeaders = {
  "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, content-type, apikey, x-client-info",
};

// ---------------------------------------------------------------------------
// Anthropic — Messages API, Sonnet 4.6, ingen thinking (latency > ræsonnement på 1 sætning;
// Sonnet valgt over Haiku for renere dansk — ADR: cost er ikke en beslutnings-akse her).
// ---------------------------------------------------------------------------
const ANTHROPIC_URL = "https://api.anthropic.com/v1/messages";
const MODEL = "claude-sonnet-4-6";
const ANTHROPIC_VERSION = "2023-06-01";

// Brand-voice (PRODUCT.md: Monumental, ceremoniel, håndsat — trykt festprogram, IKKE TV-broadcast)
// + tone-kalibrering pr. discipline_type (DimDiscipline.discipline_type).
const SYSTEM_PROMPT = `Du er kommentator-stemmen på en privat 40-års fødselsdags-scoretavle. Skriv ÉN stram dansk sætning (max ~95 tegn) til en netop-låst disciplin — to korte sætninger kun hvis det virkelig løfter dramaet. Kommentaren står som hero i et stort display-felt og må ALDRIG beskæres, så vær kort og rammende.

VÆLG ÉT GREB pr. kommentar: enten holdets skabelsesberetning/tilnavn, ELLER stillingen — ikke begge på én gang. At proppe motto + navne + stilling ind i samme sætning gør den lang og rodet. Nævn sjældent medlemmer ved navn.

Stemme: tør, editorial-vittig — som en redaktør i et nøje sat trykt festprogram, IKKE en TV-sportskommentator. Monumental og ceremoniel, men med et glimt i øjet. Ingen råb, ingen emoji, ingen udråbstegn-spam, ingen "OG DET ER MÅÅL". Tredje person, nutid.

TAL (dansk typografi): kardinaltal under 10 skrives som ord (en/et, to, tre, fire, fem, seks, syv, otte, ni); 10 og derover skrives som cifre (10, 17, 60). Etablerede talkoncepter bevares altid som tal (dart-180, 80'erne, 90'erne).

HOLD: hvert hold har et kongerige-navn efter farve (fx Rødt Kongerige), plus et selvvalgt tilnavn og en selvskrevet skabelsesberetning, som holdet finder på undervejs på dagen. Læs tilnavn og skabelsesberetning når de er der, og spil på dem når det giver en sjov eller præcis pointe — det er holdets egen identitet, ikke noget du opfinder. Mangler de, så kommentér bare på spillet uden at savne dem.

RESULTAT: gengiv rå-resultatet som det er i disciplinens egne termer (fx dart-score 180). Opfind aldrig fag-jargon eller termer du ikke er sikker på.

Tone pr. disciplin-type:
- Skill: anerkend håndværket og præcisionen.
- Knowledge: tør, lidt skolet, klogeagtig.
- Creative: legende, billedrig.
- Luck: ironisk distance — held er ingen dyd, ikke en bedrift.

Find aldrig på fakta. Returnér KUN kommentaren — ingen anførselstegn, ingen forklaring, ingen overskrift.`;

// ---------------------------------------------------------------------------
// Bygger user-turn-konteksten fra payloaden. Holder den læsbar for modellen.
// ---------------------------------------------------------------------------
function buildUserMessage(p: Record<string, unknown>): string {
  // team/discipline/standings forventes; resten er valgfrit drama-krydderi.
  const team = (p.team ?? {}) as Record<string, unknown>;
  const disc = (p.discipline ?? {}) as Record<string, unknown>;
  const standings = (p.standings ?? {}) as Record<string, unknown>;

  // skabelsesberetning er det kanoniske felt; motto accepteres som bagud-kompatibelt alias.
  const skabelsesberetning = team.skabelsesberetning ?? team.motto;

  // Hver linje = ét faktum modellen må læne sig på. Udeladte felter springes over.
  const lines: string[] = [];
  lines.push(`Hold (kongerige): ${team.name ?? "ukendt hold"}`);
  if (team.tilnavn) lines.push(`Tilnavn (selvvalgt): ${team.tilnavn}`);
  if (skabelsesberetning) lines.push(`Skabelsesberetning (selvskrevet): ${skabelsesberetning}`);
  if (team.members) lines.push(`Medlemmer: ${team.members}`);
  lines.push(`Disciplin: ${disc.name ?? "ukendt"} (type: ${disc.type ?? "ukendt"})`);
  lines.push(`Placerings-point netop låst: ${p.points ?? "?"} (placering ${p.rank ?? "?"} af 5)`);
  if (p.raw_value !== undefined && p.raw_value !== null) lines.push(`Rå-resultat: ${p.raw_value}`);
  if (p.notes) lines.push(`Drama-noter: ${p.notes}`);
  lines.push(
    `Stilling: fører er ${standings.leader ?? "ukendt"}` +
      (standings.gap !== undefined && standings.gap !== null
        ? `, dette hold er ${standings.gap} point bagud`
        : ""),
  );

  return `Kommentér denne netop-låste disciplin:\n\n${lines.join("\n")}`;
}

// ---------------------------------------------------------------------------
// Handler
// ---------------------------------------------------------------------------
Deno.serve(async (req) => {
  // Preflight
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
        max_tokens: 64, // hård loft ~95-tegn-budget; holder svartid + display-fit
        system: SYSTEM_PROMPT,
        messages: [{ role: "user", content: buildUserMessage(payload) }],
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
    // content er en liste af blocks; vi vil have den første text-block.
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
