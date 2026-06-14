-- mk40-dashboard schema (live-input-version)
-- Per festdashboard.md ## Datamodel (locked 2026-05-12, dashboard-002)
-- og festdashboard-adr.md ## Datamodel-delta (locked 2026-05-21, dashboard-003)
-- Forfinet 2026-06-07 (dashboard-009): raw_value + sort_direction tilføjet, RLS aktiveret.
--
-- LIVE-INPUT-MODEL (locked 2026-06-07):
--   raw_value = ENESTE sandhed. Kaptajnen taster sit eget holds rå-resultat (kegler/
--   sekunder/slag). Placering (1.-5. → 10/7/5/3/1) UDLEDES live af rå-tal + sort_direction
--   — både på TV og i host-view, af samme ranking-funktion. Den rå måleenhed bevares
--   struktureret i raw_value; `notes` er drama-prosa til callouts.
--   `points` = placerings-point-SNAPSHOT skrevet af host ved låsning (audit/fallback).
--   `is_final` = LÅS-flag: host validerer rå-tallene og fryser grenen. Først ved låsning
--   tæller grenens point med i holdets total. Provisorisk visning (per-gren bars) sker
--   uafhængigt af is_final via live derivation fra raw_value.
--
-- Scope for denne fil: 3 kerne-tabeller (FactScore, DimTeam, DimDiscipline).
-- FactObservation + MusicQuizKey tilføjes i senere session (dashboard-012/013).
--
-- Kør i Supabase SQL Editor: paste hele filen og tryk Run.
-- Idempotent: kan køres flere gange uden fejl (DROP IF EXISTS oprydning øverst).

-- ============================================================================
-- 1. Drop existing (idempotency under iteration)
-- ============================================================================
drop table if exists public."FactScore" cascade;
drop table if exists public."DimTeam" cascade;
drop table if exists public."DimDiscipline" cascade;

-- ============================================================================
-- 2. DimTeam — de 5 kongeriger
-- ============================================================================
create table public."DimTeam" (
    team_key      smallint primary key,
    team_color    text not null,        -- pink, navy, grøn, orange, lilla (bandana-navne; driver --team-{navn})
    team_name     text not null,        -- kongerige-navn (kaptajn sætter via Skabelsesberetningen)
    team_short    text,                 -- kælenavn / kort navn til bump-chart-labels
    team_motto    text,                 -- kort motto/slogan (vises på dashboard-kortet)
    team_creation text,                 -- fuld skabelsesberetning (lang; AI-callout-kontekst)
    team_members  text                  -- komma-sep liste (AI-context, ikke join-target)
);

comment on table public."DimTeam" is 'De 5 hold (kongeriger). Denormaliseret members-liste fordi bridge-tabel er overkill for 28 gæster.';
comment on column public."DimTeam".team_motto is 'Creation-myth-tekst fra kongerige-afstemningen. AI-fodres som hold-kontekst i callouts.';
comment on column public."DimTeam".team_members is 'Komma-sep gæster på holdet. AI-context kun — ikke FK-target.';

-- ============================================================================
-- 3. DimDiscipline — discipliner med type, max-points og sorterings-retning
-- ============================================================================
create table public."DimDiscipline" (
    discipline_key   smallint primary key,
    discipline_name  text not null,
    discipline_type  text not null check (discipline_type in ('Skill', 'Knowledge', 'Creative', 'Luck')),
    max_points       smallint not null,
    sort_direction   text not null default 'desc' check (sort_direction in ('asc', 'desc')),
    planned_start    timestamptz,
    planned_end      timestamptz
);

comment on column public."DimDiscipline".discipline_type is 'Narrativ-håndtag for LLM tone-kalibrering. Skill != Creative != Luck.';
comment on column public."DimDiscipline".max_points is 'Loft for placerings-point (10 på alle grene → eksakt lige vægt).';
comment on column public."DimDiscipline".sort_direction is 'Hvilken vej vinder: desc = højeste raw_value vinder (dart, kegler, stemmer); asc = laveste vinder (sekunder, antal slag).';

-- ============================================================================
-- 4. FactScore — én row per (hold × disciplin × runde)
-- ============================================================================
create table public."FactScore" (
    score_id          bigint generated always as identity primary key,
    team_key          smallint not null references public."DimTeam"(team_key),
    discipline_key    smallint not null references public."DimDiscipline"(discipline_key),
    score_timestamp   timestamptz not null default now(),
    round_number      smallint not null default 1,    -- degenerate dim; musikquiz kan have 1..N
    raw_value         numeric,                        -- holdets faktiske måleresultat (sandheden)
    points            smallint,                       -- placerings-point-snapshot, sat af host ved låsning
    is_final          boolean not null default false, -- LÅS-flag fra host-view
    notes             text,                           -- fri tekst, AI-fodret drama-kontekst
    breakdown         text,                           -- per-spiller rå-scores (bowling/dart): "Anne: 180 · Bo: 150"; raw_value = snittet heraf. NULL for kollektive grene.

    -- Én aktiv row per (hold × disciplin × runde) → kaptajn-upsert er idempotent,
    -- og live-derivation har præcis ét rå-tal at rangere pr. hold.
    constraint uq_factscore_team_disc_round unique (team_key, discipline_key, round_number),

    -- Placerings-point-clamp (ADR-2): kun lovlige placerings-værdier eller endnu-ikke-låst.
    -- Stærkere end et rent max_points-loft — håndhæver selve 10/7/5/3/1-modellen.
    -- (Cross-table max_points kan ikke være en simpel CHECK; alle max_points=10 gør det moot.)
    constraint chk_factscore_points check (points is null or points in (1, 3, 5, 7, 10))
);

create index idx_factscore_team_disc on public."FactScore"(team_key, discipline_key);
create index idx_factscore_timestamp on public."FactScore"(score_timestamp desc);

comment on table public."FactScore" is 'Transactional fact. raw_value = sandhed; points = placerings-snapshot ved låsning; is_final = host-lås.';
comment on column public."FactScore".raw_value is 'Holdets faktiske resultat (kegler/sekunder/slag/stemmer). Rangeres mod sort_direction → placerings-point.';
comment on column public."FactScore".points is 'Placerings-point (10/7/5/3/1) skrevet af host ved låsning. NULL indtil låst. Audit/fallback — TV udleder live fra raw_value.';
comment on column public."FactScore".is_final is 'Host har valideret + låst grenen. Først da tæller point med i totalen.';
comment on column public."FactScore".notes is 'Fri tekst, fx "5 strikes i træk". Uden noter bliver callouts intetsigende.';

-- ============================================================================
-- 5. Row Level Security — anon læser alt, skriver kun FactScore
-- ============================================================================
-- Per dashboard-009 (2026-06-07) + ADR-2: fuld tillid + DB-clamp, ingen godkendelses-flow.
-- Public scoretavle = ingen privat data. Kaptajner (anon) inserter/opdaterer eget holds
-- raw_value; host (anon) skriver points + is_final ved låsning. Dim-tabeller er read-only
-- for anon (seedes af ejeren via service-role i SQL Editor).
alter table public."DimTeam"       enable row level security;
alter table public."DimDiscipline" enable row level security;
alter table public."FactScore"     enable row level security;

-- Læsning for alle (TV, kaptajn-view, host-view kører alle på anon-key).
create policy "anon_read_DimTeam"       on public."DimTeam"       for select to anon using (true);
create policy "anon_read_DimDiscipline" on public."DimDiscipline" for select to anon using (true);
create policy "anon_read_FactScore"     on public."FactScore"     for select to anon using (true);

-- Skrivning på FactScore: insert (kaptajn-upsert) + update (kaptajn-rettelse + host-lås).
-- points-clamp håndhæves af chk_factscore_points uanset hvem der skriver.
create policy "anon_insert_FactScore" on public."FactScore" for insert to anon with check (true);
create policy "anon_update_FactScore" on public."FactScore" for update to anon using (true) with check (true);

-- Bevidst INGEN delete-policy og INGEN write-policy på Dim-tabeller for anon.
