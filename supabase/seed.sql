-- mk40-dashboard seed-data (skeleton-version)
-- Plausible dummy-data så frontenden kan render en troværdig scoretavle.
-- Hold-medlemmer + mottos er PLACEHOLDERS — udskiftes når rigtige gæster bekræfter.
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
-- 3. DimDiscipline — 5 discipliner
-- ============================================================================
insert into public."DimDiscipline" (discipline_key, discipline_name, discipline_type, max_points) values
    (1, 'Bowling',     'Skill',      20),
    (2, 'Dart',        'Skill',     100),
    (3, 'Cornhole',    'Skill',      21),
    (4, 'Boblere',     'Luck',       15),  -- slå-søm + øl-bowling samlet
    (5, 'Musikquiz',   'Knowledge',  30);  -- 10 sange × 3 point (titel/kunstner/år)

-- ============================================================================
-- 4. FactScore — 25 rows, én per hold × disciplin, alle is_final
-- ============================================================================
-- Point varierer for at vise rangering. Notes inkluderer dummy LLM-context.
insert into public."FactScore" (team_key, discipline_key, points, is_final, notes) values
    -- Bowling (max 20) — Røde dominerer
    (1, 1, 18, true,  '6 strikes i træk, ufattelig serie'),
    (2, 1, 12, true,  null),
    (3, 1, 15, true,  'Lars hev dem op fra nul i 8. frame'),
    (4, 1,  9, true,  'Mest gutter, men jubel i sidste runde'),
    (5, 1, 14, true,  null),

    -- Dart (max 100) — Blå har dart-mester
    (1, 2, 67, true,  null),
    (2, 2, 91, true,  'Gustav lukkede med dobbel-16, hele lokalet rejste sig'),
    (3, 2, 54, true,  null),
    (4, 2, 78, true,  'Sofie kom ud af ingenting med tre triple-19''ere'),
    (5, 2, 49, true,  null),

    -- Cornhole (max 21) — Grønne specialitet
    (1, 3, 12, true,  null),
    (2, 3, 15, true,  null),
    (3, 3, 21, true,  'Skin shot på sidste pose — perfekt 21'),
    (4, 3, 18, true,  null),
    (5, 3, 14, true,  'Tæt match mod Gyldne, tabte i overtime'),

    -- Boblere (max 15) — Gyldne har morgen-energien
    (1, 4,  8, true,  null),
    (2, 4,  6, true,  'Slog søm skævt i tre forsøg'),
    (3, 4, 11, true,  null),
    (4, 4, 14, true,  'Wilma rev fire øl-flasker i træk uden at spilde'),
    (5, 4,  9, true,  null),

    -- Musikquiz (max 30) — Sorte er music nerds
    (1, 5, 19, true,  null),
    (2, 5, 22, true,  'Vidste alle 80er-hits men savnede de nye'),
    (3, 5, 17, true,  null),
    (4, 5, 14, true,  null),
    (5, 5, 27, true,  'Genkendte tre sange på første tone — uhyggeligt');
