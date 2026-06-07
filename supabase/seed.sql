-- mk40-dashboard seed-data (placerings-point-version)
-- Plausible dummy-data så frontenden kan render en troværdig, DYNAMISK scoretavle.
-- Hold-medlemmer + mottos er PLACEHOLDERS — udskiftes når rigtige gæster bekræfter.
--
-- SCORE-MODEL (locked 2026-06-06): placerings-point, ikke rå-point.
--   Hver disciplin rangerer holdene 1.–5. plads → 10 / 7 / 5 / 3 / 1.
--   max_points = 10 (førstepladsen) på ALLE discipliner → hver gren vejer eksakt ens.
--   Den rå måleenhed (kegler, sekunder, antal slag) lever i `notes` som callout-kontekst.
--   Resultat: tavlen er dynamisk; ingen disciplin dominerer, holdene hopper.
--
-- Den seedede konkurrence ender tæt: Røde 39 · Blå 38 · Gyldne 37 · Grønne 36 · Sorte 32.
-- Føringen skifter undervejs (Blå → Røde → Blå → Sorte → Røde) så bump-chartet får liv.
--
-- Kør efter schema.sql. Idempotent: kan re-køres for at nulstille til kendt state.

-- ============================================================================
-- 1. Clear existing data (idempotency)
-- ============================================================================
truncate table public."FactScore" restart identity cascade;
truncate table public."DimTeam" cascade;
truncate table public."DimDiscipline" cascade;

-- ============================================================================
-- 2. DimTeam — 5 kongeriger
-- ============================================================================
insert into public."DimTeam" (team_key, team_color, team_name, team_motto, team_members) values
    (1, 'rød',       'Kongeriget Røde Rødder',  'Vi rødder ikke for sjov',                  'Anne, Bo, Carl, Dorthe, Erik, Frida'),
    (2, 'blå',       'Det Blå Imperium',         'Bølgen tager alt',                          'Gustav, Helle, Ivan, Julie, Kasper'),
    (3, 'grøn',      'Den Grønne Pagt',          'Vi spirer, vi gror, vi vinder',             'Lars, Mette, Nina, Oscar, Peter, Rikke'),
    (4, 'gul',       'Gyldne Riger',             'Sol over alt',                              'Sofie, Thomas, Ulla, Viktor, Wilma'),
    (5, 'sort/hvid', 'Den Sorte Cirkel',         'I skyggen vinder vi',                       'Xenia, Yvonne, Zander, Aksel, Bente, Christian');

-- ============================================================================
-- 3. DimDiscipline — 7 discipliner, alle max_points=10 (placerings-point-loft)
-- ============================================================================
-- discipline_type = narrativ-håndtag til LLM tone (Skill/Knowledge/Creative/Luck).
-- planned_start/end matcher dagsprogrammet (Creation Myth afstemmes under maden;
-- de 4 stationer er åbne i konkurrence-vinduet 16–21).
insert into public."DimDiscipline" (discipline_key, discipline_name, discipline_type, max_points, planned_start, planned_end) values
    (1, 'Creation Myth',    'Creative',  10, '2026-06-27 19:30+02', '2026-06-27 20:00+02'),
    (2, 'Bowling',          'Skill',     10, '2026-06-27 14:00+02', '2026-06-27 16:00+02'),
    (3, 'Dart',             'Skill',     10, '2026-06-27 16:00+02', '2026-06-27 21:00+02'),
    (4, 'Cornhole',         'Skill',     10, '2026-06-27 16:00+02', '2026-06-27 21:00+02'),
    (5, 'Puslespil på tid', 'Skill',     10, '2026-06-27 16:00+02', '2026-06-27 21:00+02'),
    (6, 'Slå søm',          'Luck',      10, '2026-06-27 16:00+02', '2026-06-27 21:00+02'),
    (7, 'Musikquiz',        'Knowledge', 10, '2026-06-27 21:00+02', '2026-06-27 22:00+02');

-- ============================================================================
-- 4. FactScore — 35 rows, én per (hold × disciplin), alle is_final
-- ============================================================================
-- points = placerings-point (10/7/5/3/1). notes = rå resultat + drama (LLM-kontekst).
-- score_timestamp i KRONOLOGISK afviklingsrækkefølge så bump-chartet viser bevægelse:
--   Bowling 16:00 → Dart 16:45 → Cornhole 17:30 → Puslespil 18:15 → Slå søm 19:00
--   → Creation Myth-afstemning 19:45 (under maden) → Musikquiz 21:45 (finale).
insert into public."FactScore" (team_key, discipline_key, score_timestamp, points, is_final, notes) values
    -- Bowling (key 2) — Blå fører tidligt
    (1, 2, '2026-06-27 16:00:01+02',  7, true,  '171 i snit — stabil hele vejen'),
    (2, 2, '2026-06-27 16:00:02+02', 10, true,  '198 kegler i snit, en 7-10 split-konvertering fik hele banen op at stå'),
    (3, 2, '2026-06-27 16:00:03+02',  3, true,  null),
    (4, 2, '2026-06-27 16:00:04+02',  5, true,  null),
    (5, 2, '2026-06-27 16:00:05+02',  1, true,  'Strike-tørke — Den Sorte Cirkel fandt aldrig rytmen'),

    -- Dart (key 3) — Røde overtager føringen
    (1, 3, '2026-06-27 16:45:01+02', 10, true,  'Lukkede på dobbel-tops med sidste pil — baren eksploderede'),
    (2, 3, '2026-06-27 16:45:02+02',  5, true,  null),
    (3, 3, '2026-06-27 16:45:03+02',  1, true,  'Ramte mest væggen — dart er ikke Den Grønne Pagts gren'),
    (4, 3, '2026-06-27 16:45:04+02',  3, true,  null),
    (5, 3, '2026-06-27 16:45:05+02',  7, true,  'Tre triple-19''ere reddede Den Sorte Cirkel'),

    -- Cornhole (key 4) — Grønne specialitet, Blå tilbage på toppen
    (1, 4, '2026-06-27 17:30:01+02',  3, true,  null),
    (2, 4, '2026-06-27 17:30:02+02',  7, true,  null),
    (3, 4, '2026-06-27 17:30:03+02', 10, true,  'Skin shot på sidste pose — perfekt afslutning'),
    (4, 4, '2026-06-27 17:30:04+02',  1, true,  'Poserne ville ikke ligge i hul for Gyldne Riger'),
    (5, 4, '2026-06-27 17:30:05+02',  5, true,  null),

    -- Puslespil på tid (key 5) — Gyldne henter sig op
    (1, 5, '2026-06-27 18:15:01+02',  1, true,  'Gik i stå på det blå himmel-stykke og tabte tempoet'),
    (2, 5, '2026-06-27 18:15:02+02',  3, true,  null),
    (3, 5, '2026-06-27 18:15:03+02',  7, true,  null),
    (4, 5, '2026-06-27 18:15:04+02', 10, true,  'Samlede 50 brikker på 6 min — fire hænder i sync'),
    (5, 5, '2026-06-27 18:15:05+02',  5, true,  null),

    -- Slå søm (key 6) — Sorte tager føringen for første gang
    (1, 6, '2026-06-27 19:00:01+02',  5, true,  null),
    (2, 6, '2026-06-27 19:00:02+02',  1, true,  'Ramte fingeren oftere end sømmet'),
    (3, 6, '2026-06-27 19:00:03+02',  3, true,  null),
    (4, 6, '2026-06-27 19:00:04+02',  7, true,  null),
    (5, 6, '2026-06-27 19:00:05+02', 10, true,  'Sænkede alle 6 søm på 9 slag — kirurgisk'),

    -- Creation Myth-afstemning (key 1) — Røde tilbage i front under maden
    (1, 1, '2026-06-27 19:45:01+02', 10, true,  'Myten om de salige rødder under jorden tog flest stemmer'),
    (2, 1, '2026-06-27 19:45:02+02',  5, true,  null),
    (3, 1, '2026-06-27 19:45:03+02',  7, true,  'Spire-sagaen var en tæt 2''er'),
    (4, 1, '2026-06-27 19:45:04+02',  1, true,  null),
    (5, 1, '2026-06-27 19:45:05+02',  3, true,  null),

    -- Musikquiz (key 7) — finalen, Gyldne brager op men Røde holder
    (1, 7, '2026-06-27 21:45:01+02',  3, true,  null),
    (2, 7, '2026-06-27 21:45:02+02',  7, true,  'Vidste alle 80''er-hits'),
    (3, 7, '2026-06-27 21:45:03+02',  5, true,  null),
    (4, 7, '2026-06-27 21:45:04+02', 10, true,  'Genkendte tre sange på første tone — uhyggeligt'),
    (5, 7, '2026-06-27 21:45:05+02',  1, true,  'Tabte på de nye hits trods favorit-status');
