-- mk40-dashboard seed-data (live-input-version)
-- Plausible dummy-data så frontenden kan render en troværdig, DYNAMISK scoretavle.
-- Hold-medlemmer + mottos er PLACEHOLDERS — udskiftes når rigtige gæster bekræfter.
--
-- SCORE-MODEL (locked 2026-06-06, forfinet 2026-06-07):
--   raw_value = holdets faktiske resultat (sandheden). Placering udledes live:
--   ranger holdene på raw_value mod sort_direction → 10 / 7 / 5 / 3 / 1.
--   max_points = 10 på ALLE grene → hver gren vejer eksakt ens.
--   points-kolonnen her = det placerings-snapshot host VILLE skrive ved låsning
--   (alle rows is_final=true = en færdigspillet demo-konkurrence).
--   `notes` = rå resultat i prosa + drama (LLM-callout-kontekst).
--
-- sort_direction pr. gren:
--   desc (højest vinder): Creation Myth (stemmer), Bowling (kegler), Dart, Cornhole, Musikquiz (rigtige)
--   asc  (lavest vinder): Puslespil på tid (sekunder), Slå søm (antal slag)
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
-- 3. DimDiscipline — 7 discipliner, alle max_points=10, m. sort_direction
-- ============================================================================
insert into public."DimDiscipline" (discipline_key, discipline_name, discipline_type, max_points, sort_direction, planned_start, planned_end) values
    (1, 'Creation Myth',    'Creative',  10, 'desc', '2026-06-27 19:30+02', '2026-06-27 20:00+02'),
    (2, 'Bowling',          'Skill',     10, 'desc', '2026-06-27 14:00+02', '2026-06-27 16:00+02'),
    (3, 'Dart',             'Skill',     10, 'desc', '2026-06-27 16:00+02', '2026-06-27 21:00+02'),
    (4, 'Cornhole',         'Skill',     10, 'desc', '2026-06-27 16:00+02', '2026-06-27 21:00+02'),
    (5, 'Puslespil på tid', 'Skill',     10, 'asc',  '2026-06-27 16:00+02', '2026-06-27 21:00+02'),
    (6, 'Slå søm',          'Luck',      10, 'asc',  '2026-06-27 16:00+02', '2026-06-27 21:00+02'),
    (7, 'Musikquiz',        'Knowledge', 10, 'desc', '2026-06-27 21:00+02', '2026-06-27 22:00+02');

-- ============================================================================
-- 4. FactScore — 35 rows, én per (hold × disciplin), alle is_final
-- ============================================================================
-- raw_value = faktisk resultat; points = udledt placering (10/7/5/3/1); notes = drama.
-- score_timestamp i KRONOLOGISK afviklingsrækkefølge så bump-chartet viser bevægelse:
--   Bowling 16:00 → Dart 16:45 → Cornhole 17:30 → Puslespil 18:15 → Slå søm 19:00
--   → Creation Myth-afstemning 19:45 (under maden) → Musikquiz 21:45 (finale).
insert into public."FactScore" (team_key, discipline_key, score_timestamp, raw_value, points, is_final, notes) values
    -- Bowling (key 2, desc — kegler i snit) — Blå fører tidligt
    (1, 2, '2026-06-27 16:00:01+02', 171,  7, true,  '171 i snit — stabil hele vejen'),
    (2, 2, '2026-06-27 16:00:02+02', 198, 10, true,  '198 kegler i snit, en 7-10 split-konvertering fik hele banen op at stå'),
    (3, 2, '2026-06-27 16:00:03+02', 142,  3, true,  null),
    (4, 2, '2026-06-27 16:00:04+02', 158,  5, true,  null),
    (5, 2, '2026-06-27 16:00:05+02', 121,  1, true,  'Strike-tørke — Den Sorte Cirkel fandt aldrig rytmen'),

    -- Dart (key 3, desc — samlet score) — Røde overtager føringen
    (1, 3, '2026-06-27 16:45:01+02', 180, 10, true,  'Lukkede på dobbel-tops med sidste pil — baren eksploderede'),
    (2, 3, '2026-06-27 16:45:02+02', 134,  5, true,  null),
    (3, 3, '2026-06-27 16:45:03+02',  92,  1, true,  'Ramte mest væggen — dart er ikke Den Grønne Pagts gren'),
    (4, 3, '2026-06-27 16:45:04+02', 118,  3, true,  null),
    (5, 3, '2026-06-27 16:45:05+02', 156,  7, true,  'Tre triple-19''ere reddede Den Sorte Cirkel'),

    -- Cornhole (key 4, desc — point) — Grønne specialitet, Blå tilbage på toppen
    (1, 4, '2026-06-27 17:30:01+02',  11,  3, true,  null),
    (2, 4, '2026-06-27 17:30:02+02',  18,  7, true,  null),
    (3, 4, '2026-06-27 17:30:03+02',  21, 10, true,  'Skin shot på sidste pose — perfekt afslutning'),
    (4, 4, '2026-06-27 17:30:04+02',   7,  1, true,  'Poserne ville ikke ligge i hul for Gyldne Riger'),
    (5, 4, '2026-06-27 17:30:05+02',  15,  5, true,  null),

    -- Puslespil på tid (key 5, asc — sekunder, lavest vinder) — Gyldne henter sig op
    (1, 5, '2026-06-27 18:15:01+02', 540,  1, true,  'Gik i stå på det blå himmel-stykke og tabte tempoet (9 min)'),
    (2, 5, '2026-06-27 18:15:02+02', 475,  3, true,  null),
    (3, 5, '2026-06-27 18:15:03+02', 395,  7, true,  null),
    (4, 5, '2026-06-27 18:15:04+02', 360, 10, true,  'Samlede 50 brikker på 6 min — fire hænder i sync'),
    (5, 5, '2026-06-27 18:15:05+02', 430,  5, true,  null),

    -- Slå søm (key 6, asc — antal slag, færrest vinder) — Sorte tager føringen for første gang
    (1, 6, '2026-06-27 19:00:01+02',  15,  5, true,  null),
    (2, 6, '2026-06-27 19:00:02+02',  26,  1, true,  'Ramte fingeren oftere end sømmet'),
    (3, 6, '2026-06-27 19:00:03+02',  19,  3, true,  null),
    (4, 6, '2026-06-27 19:00:04+02',  12,  7, true,  null),
    (5, 6, '2026-06-27 19:00:05+02',   9, 10, true,  'Sænkede alle 6 søm på 9 slag — kirurgisk'),

    -- Creation Myth-afstemning (key 1, desc — stemmer) — Røde tilbage i front under maden
    (1, 1, '2026-06-27 19:45:01+02',  11, 10, true,  'Myten om de salige rødder under jorden tog flest stemmer'),
    (2, 1, '2026-06-27 19:45:02+02',   6,  5, true,  null),
    (3, 1, '2026-06-27 19:45:03+02',   9,  7, true,  'Spire-sagaen var en tæt 2''er'),
    (4, 1, '2026-06-27 19:45:04+02',   2,  1, true,  null),
    (5, 1, '2026-06-27 19:45:05+02',   4,  3, true,  null),

    -- Musikquiz (key 7, desc — rigtige svar) — finalen, Gyldne brager op men Røde holder
    (1, 7, '2026-06-27 21:45:01+02',   9,  3, true,  null),
    (2, 7, '2026-06-27 21:45:02+02',  15,  7, true,  'Vidste alle 80''er-hits'),
    (3, 7, '2026-06-27 21:45:03+02',  12,  5, true,  null),
    (4, 7, '2026-06-27 21:45:04+02',  18, 10, true,  'Genkendte tre sange på første tone — uhyggeligt'),
    (5, 7, '2026-06-27 21:45:05+02',   5,  1, true,  'Tabte på de nye hits trods favorit-status');
