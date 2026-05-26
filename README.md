# mk40-dashboard

Live scoretavle til Mads Knutzons 40 års fest, 27. juni 2026. 28 gæster, 5 hold, 5 discipliner — point opdateres live på TV'et og hver scoreændring trigger en kort AI-genereret kommentar.

## Stack

- **Data:** Supabase (Postgres, EU/Frankfurt, free tier)
- **Frontend:** Statisk HTML/CSS/JS hostet på GitHub Pages
- **Callouts:** Anthropic Claude Haiku 4.5 via Supabase Edge Function (LLM-proxy)
- **Real-time:** Polling hvert 5. sekund

Fuld arkitektur-rationale: `C:\Repositories\Cortex\Claude\gtd\projects\festdashboard-adr.md`

## Datamodel

Kimball-stjerneskema: `FactScore` + `DimTeam` + `DimDiscipline` + display-only `MusicQuizKey` + `FactObservation` (gæste-strøm).

Fuldt skema: `C:\Repositories\Cortex\Claude\gtd\projects\festdashboard.md` → `## Datamodel`.

## Status

Under udvikling. Hard fallback til whiteboard hvis testkørsel 13/6 ikke står 6/6.

## Lokal udvikling

Krav: Supabase-projekt med tabel-schema kørt (se `supabase/schema.sql`) og credentials i `.env.local`.

```bash
# Server statisk site lokalt (Python eller npx)
python -m http.server 8000
# eller
npx serve .
```

Åbn http://localhost:8000

## Læringsartefakt

Dette repo er artefaktet for Level 4 milestones #3 og #4 i `claude-learning-path.md`:
- Build one fully autonomous Claude Code workflow end-to-end
- Build one API-powered artifact
