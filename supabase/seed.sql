-- mk40-dashboard seed-data
-- =====================================================================================
-- TEST-RESET STATE (2026-06-14, dashboard-005 søndags 5-kaptajn-testkørsel):
--   Denne fil nulstiller DB'en til den state søndagstesten kører på:
--     · DimTeam        = de 5 LÅSTE hold (rigtige navne, fra TEAMS-arrayet i qr.html)
--     · DimDiscipline  = 7 grene (uændret)
--     · FactScore      = TOM (0 rows) → kaptajner taster alt live = den sandeste
--                        input→DB→TV→callout-test. Board starter på empty-state.
--
--   Idempotent: truncate restart identity cascade + insert. Kan re-køres.
--   Kør efter schema.sql. Mads kører den i Supabase SQL-editoren.
--
-- FARVER (bandana-migration gennemført 2026-06-14):
--   team_color seedes med bandana-NAVNENE (pink/navy/grøn/gul/lilla). De driver
--   --team-{navn}-opslaget på ALLE dashboard-sider via cssVarSafe(team_color), efter at
--   CSS-var-nøglerne er omdøbt fra de gamle farver (rød/blå/gul/sort-hvid) til bandana-
--   navnene i samme pass (style.css :root = base/dark-værdier; cards-h/hud2/hud3 har egne
--   light-tunede overrides). Ingen bro længere — DB og kode er aligned.
--   Mapping (team_key → color-streng → bandana): 1→pink · 2→navy · 3→grøn · 4→gul ·
--   5→lilla. Matcher kaptajn-QR-routingen (kaptajn.html?team=N).
--
-- SCORE-MODEL (locked 2026-06-06, forfinet 2026-06-07) — gælder når der seedes scores:
--   raw_value = holdets faktiske resultat (sandheden). Placering udledes live:
--   ranger holdene på raw_value mod sort_direction → 10 / 7 / 5 / 3 / 1.
--   max_points = 10 på ALLE grene → hver gren vejer eksakt ens.
--
-- DEMO-FACTSCORE (35 rows, færdigspillet demo-konkurrence) er parkeret som kommenteret
-- blok nederst — fjern kommentar for at re-aktivere en "levende" demo-tavle. Festdag-data
-- loades separat via dashboard-021, ikke herfra.
-- =====================================================================================

-- ============================================================================
-- 1. Clear existing data (idempotency)
-- ============================================================================
truncate table public."FactScore" restart identity cascade;
truncate table public."DimTeam" cascade;
truncate table public."DimDiscipline" cascade;
truncate table public."MusicQuizScore" cascade;
truncate table public."MusicQuizKey" cascade;

-- ============================================================================
-- 2. DimTeam — 5 LÅSTE kongeriger (2026-06-14, fra qr.html TEAMS-array)
-- ============================================================================
-- team_name = placeholder indtil gæsterne definerer kongerige-navn via creation-myth
--   på dagen. team_motto = null indtil da.
-- team_members = komma-sep (denormaliseret AI-context, intet join-target). Kaptajn står
--   FØRST i hver liste, men kaptajn er IKKE et DB-felt — QR'en router kun på team_key.
-- team_color = bandana-navn (se farve-note øverst); team_key matcher kaptajn-QR-routingen.
-- team_short = kort default-kælenavn til bump (kaptajnen kan overskrive via Skabelsesberetningen).
-- team_motto + team_creation = null indtil kaptajnerne udfylder dem på dagen.
insert into public."DimTeam" (team_key, team_color, team_name, team_short, team_motto, team_creation, team_members) values
    (1, 'pink',   'Det Pink Kongerige',     'Pink',   null, null, 'AH, Johanne, Theo, Tim, Morten A., Mira'),
    (2, 'navy',   'Det Mørkeblå Kongerige', 'Navy',   null, null, 'Niko, Margaux, Satya, Jesper, Dirk, Rose'),
    (3, 'grøn',   'Det Grønne Kongerige',   'Grøn',   null, null, 'Anders, Mads, Mikkel, Julie, Majbritt'),
    (4, 'gul',    'Det Gule Kongerige',     'Gul', null, null, 'Anne, Allan, Christian, Morten E., Ida, AC'),
    (5, 'lilla',  'Det Lilla Kongerige',    'Lilla',  null, null, 'Buggi, Oscar, Michael, Kirstine, Freja');

-- ============================================================================
-- 3. DimDiscipline — 7 discipliner, alle max_points=10, m. sort_direction
-- ============================================================================
-- sort_direction: desc = højest vinder (Creation Myth/Bowling/Dart/Cornhole/Musikquiz);
--                 asc  = lavest vinder (Puslespil på tid/Slå søm).
insert into public."DimDiscipline" (discipline_key, discipline_name, discipline_type, max_points, sort_direction, planned_start, planned_end) values
    (1, 'Skabelsesberetningen', 'Creative', 10, 'desc', '2026-06-27 19:30+02', '2026-06-27 20:00+02'),
    (2, 'Bowling',          'Skill',     10, 'desc', '2026-06-27 14:00+02', '2026-06-27 16:00+02'),
    (3, 'Dart',             'Skill',     10, 'desc', '2026-06-27 16:00+02', '2026-06-27 21:00+02'),
    (4, 'Cornhole',         'Skill',     10, 'desc', '2026-06-27 16:00+02', '2026-06-27 21:00+02'),
    (5, 'Puslespil på tid', 'Skill',     10, 'asc',  '2026-06-27 16:00+02', '2026-06-27 21:00+02'),
    (6, 'Slå søm',          'Luck',      10, 'asc',  '2026-06-27 16:00+02', '2026-06-27 21:00+02'),
    (7, 'Musikquiz',        'Knowledge', 10, 'desc', '2026-06-27 21:00+02', '2026-06-27 22:00+02');

-- ============================================================================
-- 4. FactScore — TOM til søndagstesten (kaptajner taster live)
-- ============================================================================
-- Bevidst ingen insert. Board starter på empty-state; hver kaptajn-indtastning er en
-- ægte input→DB→TV→callout-verifikation. Festdag-data loades via dashboard-021.

-- ============================================================================
-- 5. MusicQuizKey — facit-liste til musikquizzen (dashboard-013, display-only)
-- ============================================================================
-- Mads' faktiske quiz-sange (21). round_number = quiz-rækkefølge; release_year verificeret
-- mod Wikipedia/Discogs (Claude-research 2026-06-19, kurateret m. Mads). revealed = false →
-- quizmasteren afslører hver sang live fra quiz.html; TV-quiz-siden (musikquiz.html) viser kun
-- de afslørede. Ikke scoring-koblet: musikquiz-POINT tastes uafhængigt på discipline_key=7.
--
-- Skåret ned fra 24→20-mål, landede på 21 (Mads). Fjernet: Wolfmother, The xx, Jamiroquai,
-- Blink-182. Tilføjet: Malk de Koijn (#21). Malk er lagt sidst — flyt frit hvis quiz-rækken
-- skal være en anden. OMSTRIDTE ÅR (valgt ét — skift frit): Butterfly (single 2000 / chart
-- 2001), Trouble Is (2009/2010).
insert into public."MusicQuizKey" (key_id, round_number, title, artist, release_year, revealed) values
    ( 1,  1, 'Mr. Brightside',                         'The Killers',            2003, false),
    ( 2,  2, 'Take It as It Comes',                    'Grand Avenue',           2003, false),
    ( 3,  3, 'Teenage Dirtbag',                        'Wheatus',                2000, false),
    ( 4,  4, 'Butterfly',                              'Crazy Town',             2000, false),
    ( 5,  5, 'By the Way',                             'Red Hot Chili Peppers',  2002, false),
    ( 6,  6, 'Han får for lidt',                       'Østkyst Hustlers',       1996, false),
    ( 7,  7, 'Everybody (Backstreet''s Back)',         'Backstreet Boys',        1997, false),
    ( 8,  8, 'L''Amour Toujours',                      'Gigi D''Agostino',       1999, false),
    ( 9,  9, '505',                                    'Arctic Monkeys',         2007, false),
    (10, 10, 'American Boy',                           'Estelle ft. Kanye West', 2008, false),
    (11, 11, 'Like I Love You',                        'Justin Timberlake',      2002, false),
    (12, 12, 'Trouble Is',                             'Turboweekend',           2009, false),
    (13, 13, 'Vil du',                                 'U$O',                    2005, false),
    (14, 14, 'Stuck in a Moment You Can''t Get Out Of','U2',                     2001, false),
    (15, 15, 'Transparent & Glasslike',                'Carpark North',          2003, false),
    (16, 16, 'Save Tonight',                           'Eagle-Eye Cherry',       1997, false),
    (17, 17, 'Clint Eastwood',                         'Gorillaz',               2001, false),
    (18, 18, 'Don''t Know Much About Love',            'Hanne Boel',             1992, false),
    (19, 19, 'Club Tropicana',                         'Wham!',                  1983, false),
    (20, 20, 'Never Gonna Give You Up',                'Rick Astley',            1987, false),
    (21, 21, 'Vi tager fuglen på dig',                 'Malk de Koijn',          2002, false);

-- ---------------------------------------------------------------------------
-- PARKERET: DEMO-FACTSCORE (35 rows) — fjern blok-kommentaren for at re-aktivere
-- en færdigspillet demo-tavle (tæt løb, skiftende føring, bump-chart-liv).
-- raw_value = faktisk resultat; points = udledt placering (10/7/5/3/1); notes = drama.
-- ---------------------------------------------------------------------------
/*
insert into public."FactScore" (team_key, discipline_key, score_timestamp, raw_value, points, is_final, notes) values
    -- Bowling (key 2, desc — kegler i snit)
    (1, 2, '2026-06-27 16:00:01+02', 171,  7, true,  '171 i snit — stabil hele vejen'),
    (2, 2, '2026-06-27 16:00:02+02', 198, 10, true,  '198 kegler i snit, en 7-10 split-konvertering fik hele banen op at stå'),
    (3, 2, '2026-06-27 16:00:03+02', 142,  3, true,  null),
    (4, 2, '2026-06-27 16:00:04+02', 158,  5, true,  null),
    (5, 2, '2026-06-27 16:00:05+02', 121,  1, true,  'Strike-tørke — fandt aldrig rytmen'),

    -- Dart (key 3, desc — samlet score)
    (1, 3, '2026-06-27 16:45:01+02', 180, 10, true,  'Lukkede på dobbel-tops med sidste pil — baren eksploderede'),
    (2, 3, '2026-06-27 16:45:02+02', 134,  5, true,  null),
    (3, 3, '2026-06-27 16:45:03+02',  92,  1, true,  'Ramte mest væggen — dart er ikke holdets gren'),
    (4, 3, '2026-06-27 16:45:04+02', 118,  3, true,  null),
    (5, 3, '2026-06-27 16:45:05+02', 156,  7, true,  'Tre triple-19''ere reddede holdet'),

    -- Cornhole (key 4, desc — point)
    (1, 4, '2026-06-27 17:30:01+02',  11,  3, true,  null),
    (2, 4, '2026-06-27 17:30:02+02',  18,  7, true,  null),
    (3, 4, '2026-06-27 17:30:03+02',  21, 10, true,  'Skin shot på sidste pose — perfekt afslutning'),
    (4, 4, '2026-06-27 17:30:04+02',   7,  1, true,  'Poserne ville ikke ligge i hul'),
    (5, 4, '2026-06-27 17:30:05+02',  15,  5, true,  null),

    -- Puslespil på tid (key 5, asc — sekunder, lavest vinder)
    (1, 5, '2026-06-27 18:15:01+02', 540,  1, true,  'Gik i stå på det blå himmel-stykke og tabte tempoet (9 min)'),
    (2, 5, '2026-06-27 18:15:02+02', 475,  3, true,  null),
    (3, 5, '2026-06-27 18:15:03+02', 395,  7, true,  null),
    (4, 5, '2026-06-27 18:15:04+02', 360, 10, true,  'Samlede 50 brikker på 6 min — fire hænder i sync'),
    (5, 5, '2026-06-27 18:15:05+02', 430,  5, true,  null),

    -- Slå søm (key 6, asc — antal slag, færrest vinder)
    (1, 6, '2026-06-27 19:00:01+02',  15,  5, true,  null),
    (2, 6, '2026-06-27 19:00:02+02',  26,  1, true,  'Ramte fingeren oftere end sømmet'),
    (3, 6, '2026-06-27 19:00:03+02',  19,  3, true,  null),
    (4, 6, '2026-06-27 19:00:04+02',  12,  7, true,  null),
    (5, 6, '2026-06-27 19:00:05+02',   9, 10, true,  'Sænkede alle 6 søm på 9 slag — kirurgisk'),

    -- Creation Myth-afstemning (key 1, desc — stemmer)
    (1, 1, '2026-06-27 19:45:01+02',  11, 10, true,  'Myten tog flest stemmer'),
    (2, 1, '2026-06-27 19:45:02+02',   6,  5, true,  null),
    (3, 1, '2026-06-27 19:45:03+02',   9,  7, true,  'Spire-sagaen var en tæt 2''er'),
    (4, 1, '2026-06-27 19:45:04+02',   2,  1, true,  null),
    (5, 1, '2026-06-27 19:45:05+02',   4,  3, true,  null),

    -- Musikquiz (key 7, desc — rigtige svar) — finalen
    (1, 7, '2026-06-27 21:45:01+02',   9,  3, true,  null),
    (2, 7, '2026-06-27 21:45:02+02',  15,  7, true,  'Vidste alle 80''er-hits'),
    (3, 7, '2026-06-27 21:45:03+02',  12,  5, true,  null),
    (4, 7, '2026-06-27 21:45:04+02',  18, 10, true,  'Genkendte tre sange på første tone — uhyggeligt'),
    (5, 7, '2026-06-27 21:45:05+02',   5,  1, true,  'Tabte på de nye hits trods favorit-status');
*/
