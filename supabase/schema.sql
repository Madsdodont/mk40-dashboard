-- mk40-dashboard schema (skeleton-version)
-- Per festdashboard.md ## Datamodel (locked 2026-05-12, dashboard-002)
-- og festdashboard-adr.md ## Datamodel-delta (locked 2026-05-21, dashboard-003)
--
-- Scope for denne fil: 3 kerne-tabeller (FactScore, DimTeam, DimDiscipline) til skeleton-build.
-- FactObservation + MusicQuizKey tilføjes i senere session (build-prep for wow-moment).
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
    team_color    text not null,        -- rød, blå, grøn, gul, sort/hvid
    team_name     text not null,        -- kongerige-navn (gæster definerer)
    team_motto    text,                 -- creation myth-tekst (AI-context)
    team_members  text                  -- komma-sep liste (AI-context, ikke join-target)
);

comment on table public."DimTeam" is 'De 5 hold (kongeriger). Denormaliseret members-liste fordi bridge-tabel er overkill for 28 gæster.';
comment on column public."DimTeam".team_motto is 'Creation-myth-tekst fra kongerige-afstemningen. AI-fodres som hold-kontekst i callouts.';
comment on column public."DimTeam".team_members is 'Komma-sep gæster på holdet. AI-context kun — ikke FK-target.';

-- ============================================================================
-- 3. DimDiscipline — discipliner med type og max-points
-- ============================================================================
create table public."DimDiscipline" (
    discipline_key   smallint primary key,
    discipline_name  text not null,
    discipline_type  text not null check (discipline_type in ('Skill', 'Knowledge', 'Creative', 'Luck')),
    max_points       smallint not null,
    planned_start    timestamptz,
    planned_end      timestamptz
);

comment on column public."DimDiscipline".discipline_type is 'Narrativ-håndtag for LLM tone-kalibrering. Skill != Creative != Luck.';
comment on column public."DimDiscipline".max_points is 'Loft for FactScore.points på denne disciplin. Anvendes som clamp i input-laget.';

-- ============================================================================
-- 4. FactScore — én row per scoreændring (transactional grain)
-- ============================================================================
create table public."FactScore" (
    score_id          bigint generated always as identity primary key,
    team_key          smallint not null references public."DimTeam"(team_key),
    discipline_key    smallint not null references public."DimDiscipline"(discipline_key),
    score_timestamp   timestamptz not null default now(),
    round_number      smallint not null default 1,    -- degenerate dim; musikquiz kan have 1..N
    points            smallint not null,
    is_final          boolean not null default false, -- explicit close-flag fra input-laget
    notes             text                            -- fri tekst, AI-fodret kontekst
);

create index idx_factscore_team_disc on public."FactScore"(team_key, discipline_key);
create index idx_factscore_timestamp on public."FactScore"(score_timestamp desc);

comment on table public."FactScore" is 'Transactional fact. Default: 1 row per (hold x disciplin) med is_final=true. Live-tracking (musikquiz) kan have flere rows pr. pair med round_number.';
comment on column public."FactScore".is_final is 'Sættes explicit af input-laget når disciplinen lukkes. Fallback-afledning: max(score_timestamp) per (team x discipline).';
comment on column public."FactScore".notes is 'Fri tekst. Eksempel: "5 strikes i træk". Uden noter bliver callouts intetsigende.';

-- ============================================================================
-- 5. Disable Row Level Security for skeleton-fasen
-- ============================================================================
-- Per beslutning 2026-05-26 i dashboard-004:
-- Public scoretavle = ingen privat data. Anon-key skal kunne læse.
-- Fine-grained policies (kaptajn-write, anon-read) sættes op i build-fase for input-flow.
alter table public."DimTeam" disable row level security;
alter table public."DimDiscipline" disable row level security;
alter table public."FactScore" disable row level security;
