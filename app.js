// mk40-dashboard frontend
// Design system: see DESIGN.md
// Stateless per ADR build-constraint #1: hver render-cycle henter fuld state fra Supabase.
// Score-change detection holdt i memory (forrige matrix → diff) for at trigge delight-animation.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { SUPABASE_URL, SUPABASE_ANON_KEY } from "./config.js";

const POLL_INTERVAL_MS = 5000;

// ===== Supabase client init ==================================================
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// ===== DOM refs ==============================================================
const scoreboardContainer = document.getElementById("scoreboard-container");
const lastUpdatedEl = document.getElementById("last-updated");
const connectionStateEl = document.getElementById("connection-state");

// ===== Score-change detection state ==========================================
// matrix[team_key][discipline_key] = points (number) | undefined
// Holdes på tværs af polls så vi kan diffe.
let previousMatrix = null;
let previousTotals = null;

// ===== Data fetch ============================================================
async function fetchAll() {
    const [teamsRes, disciplinesRes, scoresRes] = await Promise.all([
        supabase.from("DimTeam").select("*").order("team_key"),
        supabase.from("DimDiscipline").select("*").order("discipline_key"),
        supabase.from("FactScore").select("*").eq("is_final", true),
    ]);

    if (teamsRes.error) throw new Error(`DimTeam: ${teamsRes.error.message}`);
    if (disciplinesRes.error) throw new Error(`DimDiscipline: ${disciplinesRes.error.message}`);
    if (scoresRes.error) throw new Error(`FactScore: ${scoresRes.error.message}`);

    return {
        teams: teamsRes.data,
        disciplines: disciplinesRes.data,
        scores: scoresRes.data,
    };
}

// ===== Score aggregation =====================================================
/**
 * matrix[team_key][discipline_key] = points (newest is_final wins on duplicate).
 */
function buildScoreMatrix(scores) {
    const matrix = {};
    const timestamps = {};
    for (const row of scores) {
        if (!matrix[row.team_key]) { matrix[row.team_key] = {}; timestamps[row.team_key] = {}; }
        const existingTs = timestamps[row.team_key][row.discipline_key];
        if (!existingTs || new Date(row.score_timestamp) > new Date(existingTs)) {
            matrix[row.team_key][row.discipline_key] = row.points;
            timestamps[row.team_key][row.discipline_key] = row.score_timestamp;
        }
    }
    return matrix;
}

function totalForTeam(teamKey, disciplines, matrix) {
    let total = 0;
    for (const disc of disciplines) {
        const cell = matrix[teamKey]?.[disc.discipline_key];
        if (typeof cell === "number") total += cell;
    }
    return total;
}

/**
 * Returnerer Set af "teamKey:disciplineKey"-strings hvor cellen ændrede sig.
 */
function diffMatrix(prev, next) {
    const changed = new Set();
    if (!prev) return changed; // første render — ingen change
    for (const teamKey of Object.keys(next)) {
        for (const discKey of Object.keys(next[teamKey])) {
            if (prev[teamKey]?.[discKey] !== next[teamKey][discKey]) {
                changed.add(`${teamKey}:${discKey}`);
            }
        }
    }
    return changed;
}

function diffTotals(prev, next) {
    const changed = new Set();
    if (!prev) return changed;
    for (const teamKey of Object.keys(next)) {
        if (prev[teamKey] !== next[teamKey]) changed.add(teamKey);
    }
    return changed;
}

// ===== Rendering =============================================================

function renderState(message, isError = false) {
    scoreboardContainer.innerHTML = `<div class="state-message${isError ? " error" : ""}">${escapeHtml(message)}</div>`;
}

function renderScoreboard({ teams, disciplines, scores }) {
    if (teams.length === 0 && disciplines.length === 0 && scores.length === 0) {
        renderState("Ingen scores endnu");
        previousMatrix = null;
        previousTotals = null;
        return;
    }

    const matrix = buildScoreMatrix(scores);
    const changedCells = diffMatrix(previousMatrix, matrix);

    const totals = {};
    for (const team of teams) {
        totals[team.team_key] = totalForTeam(team.team_key, disciplines, matrix);
    }
    const changedTotals = diffTotals(previousTotals, totals);

    let html = '<table class="scoreboard"><thead><tr>';
    html += '<th class="discipline-header">Disciplin</th>';
    for (const team of teams) {
        const colorAttr = escapeAttr(team.team_color);
        html += `<th class="team-header" data-team-color="${colorAttr}" style="--team-color: var(--team-${cssVarSafe(team.team_color)})">${escapeHtml(team.team_name)}</th>`;
    }
    html += "</tr></thead><tbody>";

    for (const disc of disciplines) {
        html += `<tr><th class="discipline-cell">${escapeHtml(disc.discipline_name)}<span class="max-points">/${disc.max_points}</span></th>`;
        for (const team of teams) {
            const cell = matrix[team.team_key]?.[disc.discipline_key];
            const cellKey = `${team.team_key}:${disc.discipline_key}`;
            const isChanged = changedCells.has(cellKey);
            const isEmpty = typeof cell !== "number";
            const display = isEmpty ? "—" : cell;
            const colorVar = `var(--team-${cssVarSafe(team.team_color)})`;
            const pulseStyle = isChanged ? ` style="--team-pulse-color: color-mix(in oklch, ${colorVar} 22%, transparent)"` : "";
            const changedAttr = isChanged ? ` data-changed="true"` : "";
            const emptyClass = isEmpty ? " empty" : "";
            html += `<td class="score-cell${emptyClass}"${changedAttr}${pulseStyle}>${display}</td>`;
        }
        html += "</tr>";
    }

    // Total row
    html += '<tr class="total-row"><th class="discipline-cell">Total</th>';
    for (const team of teams) {
        const total = totals[team.team_key];
        const isChanged = changedTotals.has(team.team_key);
        const colorVar = `var(--team-${cssVarSafe(team.team_color)})`;
        const pulseStyle = isChanged ? ` style="--team-pulse-color: color-mix(in oklch, ${colorVar} 18%, transparent)"` : "";
        const changedAttr = isChanged ? ` data-changed="true"` : "";
        html += `<td class="score-cell${changedAttr ? "" : ""}"${changedAttr}${pulseStyle}>${total}</td>`;
    }
    html += "</tr></tbody></table>";

    scoreboardContainer.innerHTML = html;

    previousMatrix = matrix;
    previousTotals = totals;
}

// ===== Helpers ===============================================================

function escapeHtml(str) {
    if (str == null) return "";
    return String(str)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function escapeAttr(str) { return escapeHtml(str); }

// CSS-variable-name-safe slug fra "sort/hvid" → "sortHvid", "blå" → "blå" (CSS understøtter unicode).
function cssVarSafe(name) {
    return String(name).replace(/\//g, "").replace(/\s+/g, "");
}

// ===== Status bar ============================================================

function setConnectionOk() {
    connectionStateEl.textContent = "●";
    connectionStateEl.className = "ok";
    const time = new Date().toLocaleTimeString("da-DK", { hour: "2-digit", minute: "2-digit", second: "2-digit" });
    lastUpdatedEl.textContent = `Opdateret ${time}`;
}

function setConnectionError() {
    connectionStateEl.textContent = "●";
    connectionStateEl.className = "error";
    lastUpdatedEl.textContent = "Forbindelse afbrudt";
}

// ===== Main poll loop ========================================================

async function pollOnce() {
    try {
        const data = await fetchAll();
        renderScoreboard(data);
        setConnectionOk();
    } catch (err) {
        console.error("Poll error:", err);
        renderState(`Kunne ikke hente data — ${err.message}`, true);
        setConnectionError();
        previousMatrix = null;
        previousTotals = null;
    }
}

pollOnce();
setInterval(pollOnce, POLL_INTERVAL_MS);
