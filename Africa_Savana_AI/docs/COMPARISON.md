# Step 3 – Comparison: hand-written vs. AI implementation

- **Hand-written:** `Africa_Savana/models/savana_ca.gaml` (commit `32eb7a4`, Unit 1)
- **AI:** `Africa_Savana_AI/models/savannah_ai.gaml` after features 1–4 (commit `beaeb16`)

Both compile in GAMA 2025.6.4. Both were run headless with seed 1.0: lions
stay at 20, zebras only decrease, and total biomass rises by exactly
2,500 cells × 0.1 kg per step.

## Line-by-line differences

| # | Aspect | Hand-written | AI | Verdict |
|---|--------|--------------|----|---------|
| 1 | Section order | global → species → grid → experiment | same | equal (S1) |
| 2 | World size | `world_size` declared but unused; `shape` line commented out | no unused variable; comment states the 100 m default is used (E1) | AI cleaner |
| 3 | Magic numbers | wander amplitude `40.0` written twice in the reflexes | `wander_amplitude` global (S2) | AI better |
| 4 | Cell colour | `rgb color <- … update: …` redeclares the built-in `color` (editor info marker) | assigns built-in `color` in `init` and in `reflex grow` | AI better, see 5 |
| 5 | Colour timing | `update:` runs **before** `reflex grow`, so the map shows the biomass of the previous step | colour recomputed **after** growth, so it matches the current biomass (G4) | hand-written has a one-step lag (minor semantic error) |
| 6 | Mean biomass | `mean(grassland collect each.biomass)`, a second pass over 2,500 cells | `total_biomass / length(grassland)` | same value, AI does less work |
| 7 | Chart displays | no `type:` (default 3D; editor warning "switch to a 2d display") and redundant `refresh: every(1 #cycle)` | `type: 2d`, no refresh facet | AI better |
| 8 | Hunting | `ask zebra at_distance kill_distance { do die; }` | identical | equal (A3) |
| 9 | Execution order | lions act before zebras (declaration order) | same | equal |
| 10 | Speed parameter | read from the global inside `reflex walk` every step | **first AI version** copied it into `walk_speed` at creation (shared parent species `animal`) | **AI semantic error, fixed** (see below) |
| 11 | Requirement traceability | prose comments | spec IDs (G1, A3, O2…) in comments and commits | AI better for checking against the spec |

## Semantic error found in the AI version (fixed)

In feature 2 the agent introduced a parent species `animal` holding the
random walk. To avoid an editor redefinition notice it set
`walk_speed <- lion_speed` in each subspecies' `init`. That value is
copied **once**, so moving the "Lion speed" slider during a run had no
effect on the lions that already exist. The hand-written version did not
have this problem.

**Fix:** removed the parent species; each species' `walk` reflex now reads
`lion_speed` / `zebra_speed` directly. A headless test that sets
`lion_speed <- 3.0` at cycle 5 now shows lions moving 3 m per step afterwards.
This is shorter, but the walk reflex appears twice, as in the hand-written
version.

## Ambiguity shared by both versions

The brief says "lions are circles of size 3" and "a lion kills a zebra it
runs into". In GAMA `circle(3.0)` has **radius** 3 (6 m across), and
`at_distance 3.0` measures centre-to-centre distance between the point
agents. So a zebra dies when its centre is inside the lion's drawn disc.
That is consistent with the picture. But if "size 3" meant a diameter, both
models would draw lions twice as large as intended.
