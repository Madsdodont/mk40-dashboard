// mk40-dashboard frontend (skeleton)
// Stateless per ADR build-constraint #1: hver render-cycle henter fuld state fra Supabase.
// localStorage-snapshot fallback (constraint #2) tilføjes i senere session.
//
// Polling 5s per ADR-3. Real-time push (WebSocket/Realtime) bevidst droppet.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { SUPABASE_URL, SUPABASE_ANON_KEY } from "./config.js";

const POLL_INTERVAL_MS = 5000;

// === Supabase client init =====================================================
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// === DOM refs =================================================================
const scoreboardContainer = document.getElementById("scoreboard-container");
const lastUpdatedEl = document.getElementById("last-updated");
const connectionStateEl = document.getElementById("connection-state");

// === Data fetch ===============================================================
/**
 * Henter teams, discipliner, og scores i parallel.
 * Returnerer { teams, disciplines, scores } eller kaster fejl.
 */
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

// === Score-aggregering ========================================================
/**
 * Bygger lookup {team_key: {discipline_key: points}} for fast O(1) celle-lookup.
 * Hvis flere is_final-rows per (team x disciplin), tages den seneste (fallback per ADR).
 */
function buildScoreMatrix(scores) {
    const matrix = {};
    for (const row of scores) {
        if (!matrix[row.team_key]) matrix[row.team_key] = {};
        const existing = matrix[row.team_key][row.discipline_key];
        // Hvis duplikat: behold den seneste (højere score_timestamp vinder)
        if (!existing || new Date(row.score_timestamp) > new Date(existing.score_timestamp)) {
            matrix[row.team_key][row.discipline_key] = row;
        }
    }
    return matrix;
}

function totalForTeam(teamKey, disciplines, matrix) {
    let total = 0;
    for (const disc of disciplines) {
        const cell = matrix[teamKey]?.[disc.discipline_key];
        if (cell) total += cell.points;
    }
    return total;
}

// === Rendering ================================================================
function renderEmpty() {
    scoreboardContainer.innerHTML = `
        <div class="empty-state">
            <p>Ingen scores endnu.</p>
            <p><small>Tabellerne er tomme. Festen er ikke startet eller seed.sql er ikke kørt.</small></p>
        </div>
    `;
}

function renderError(err) {
    scoreboardContainer.innerHTML = `
        <div class="error-state">
            <p>Kunne ikke hente data</p>
            <p><small>${escapeHtml(err.message)}</small></p>
        </div>
    `;
}

function renderScoreboard({ teams, disciplines, scores }) {
    if (teams.length === 0 && disciplines.length === 0 && scores.length === 0) {
        renderEmpty();
        return;
    }

    const matrix = buildScoreMatrix(scores);

    let html = '<table class="scoreboard"><thead><tr><th>Disciplin</th>';
    for (const team of teams) {
        html += `<th class="team-header" data-team-color="${escapeAttr(team.team_color)}">${escapeHtml(team.team_name)}</th>`;
    }
    html += "</tr></thead><tbody>";

    for (const disc of disciplines) {
        html += `<tr><th>${escapeHtml(disc.discipline_name)} <small>/${disc.max_points}</small></th>`;
        for (const team of teams) {
            const cell = matrix[team.team_key]?.[disc.discipline_key];
            const display = cell ? cell.points : "—";
            html += `<td>${display}</td>`;
        }
        html += "</tr>";
    }

    // Total-række
    html += '<tr class="total-row"><th>Total</th>';
    for (const team of teams) {
        const total = totalForTeam(team.team_key, disciplines, matrix);
        html += `<td data-team-color="${escapeAttr(team.team_color)}">${total}</td>`;
    }
    html += "</tr></tbody></table>";

    scoreboardContainer.innerHTML = html;
}

// === HTML escape (defensive — notes-feltet kommer fra DB med fri tekst) ======
function escapeHtml(str) {
    if (str == null) return "";
    return String(str)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function escapeAttr(str) {
    return escapeHtml(str);
}

// === Status-bar ===============================================================
function setConnectionOk() {
    connectionStateEl.textContent = "●";
    connectionStateEl.className = "ok";
    lastUpdatedEl.textContent = `Opdateret ${new Date().toLocaleTimeString("da-DK")}`;
}

function setConnectionError() {
    connectionStateEl.textContent = "●";
    connectionStateEl.className = "error";
    lastUpdatedEl.textContent = "Forbindelse afbrudt";
}

// === Main poll loop ===========================================================
async function pollOnce() {
    try {
        const data = await fetchAll();
        renderScoreboard(data);
        setConnectionOk();
    } catch (err) {
        console.error("Poll error:", err);
        renderError(err);
        setConnectionError();
    }
}

// Initial load + repeat polling
pollOnce();
setInterval(pollOnce, POLL_INTERVAL_MS);
