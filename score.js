// mk40-dashboard — delt scoring-logik
// Per dashboard-009 live-input-model (locked 2026-06-07):
//   raw_value = sandhed. Placering (1.-5.) udledes ved at rangere holdene på raw_value
//   mod disciplinens sort_direction → placerings-point 10/7/5/3/1.
//
// Brugt af host.html (skriver points-snapshot ved låsning) og cards-h.html (live bars).
// Holdt i ÉN fil så TV og host altid rangerer ens.

// Placerings-point efter rang. Index 0 = 1. plads.
export const PLACEMENT_POINTS = [10, 7, 5, 3, 1];

/**
 * Rangér holdene på én disciplin og udled placerings-point.
 *
 * Standard competition ranking (1-2-2-4): lige raw_value deler den højere placering,
 * næste rang springer over. Det holder alle point i den lovlige mængde {10,7,5,3,1}
 * (CHECK-constraint på FactScore.points) — vigtigt fordi host SKRIVER disse ved låsning.
 *
 * @param {Array<{team_key:number, raw_value:number|null}>} rows  rå-rækker for ÉN disciplin
 * @param {"asc"|"desc"} sortDirection  asc = laveste raw vinder (sekunder, slag); desc = højeste
 * @returns {Map<number, {rank:number, points:number, raw_value:number}>}  team_key → placering
 */
export function computePlacements(rows, sortDirection) {
    const entered = rows
        .filter((r) => r.raw_value !== null && r.raw_value !== undefined)
        .map((r) => ({ team_key: r.team_key, raw_value: Number(r.raw_value) }));

    const dir = sortDirection === "asc" ? 1 : -1;
    entered.sort((a, b) => (a.raw_value - b.raw_value) * dir);

    const result = new Map();
    for (let i = 0; i < entered.length; i++) {
        const row = entered[i];
        // Competition ranking: del placering ved lige raw_value med den foregående.
        let rank = i + 1;
        if (i > 0 && entered[i - 1].raw_value === row.raw_value) {
            rank = result.get(entered[i - 1].team_key).rank;
        }
        const points = PLACEMENT_POINTS[rank - 1] ?? 0;
        result.set(row.team_key, { rank, points, raw_value: row.raw_value });
    }
    return result;
}

/**
 * Normalisér et rå-tal til 0..1 indenfor disciplinens felt, så bar-længder kan tegnes.
 * Vinderen får altid 1.0 (længst bar) uanset sort_direction; dårligste får en synlig min-længde.
 *
 * @param {number} raw          dette holds rå-tal
 * @param {number[]} allRaws    alle indtastede rå-tal på disciplinen
 * @param {"asc"|"desc"} dir
 * @returns {number} 0..1
 */
export function rawToBarFraction(raw, allRaws, dir) {
    if (allRaws.length === 0) return 0;
    const min = Math.min(...allRaws);
    const max = Math.max(...allRaws);
    if (min === max) return 1; // alle lige / kun ét hold → fuld bar
    // desc: høj = god = lang bar. asc: lav = god = lang bar.
    const frac = dir === "asc" ? (max - raw) / (max - min) : (raw - min) / (max - min);
    // Gulv på 0.12 så selv sidstepladsen har en aflæselig stump bar.
    return 0.12 + frac * 0.88;
}
