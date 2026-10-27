# AI log

Tool: Claude Code (model: Claude Opus 5.5), GAMA 2025.6.4, 2026-10-27.
Every feature was compiled with `gama-headless -xml` and checked with a
small headless test model before it was committed.

## Prompts given to the agent

1. "fix lint error" / "fix the Hello World ones too": cleaned editor
   warnings in the Unit 1 workspace (before this exercise).
2. "I want us to create a different project", followed by the assignment
   brief (5 steps) pasted verbatim. The agent then worked through the brief
   on its own; entries below are its steps.

## Agent steps

| # | Step | What the agent did | Spec IDs | Verification | Commit | Problems / changes |
|---|------|--------------------|----------|--------------|--------|--------------------|
| 0 | Specify | Wrote the specification from the Unit 1 model, plus the extension values | all | review | `55b80b9` | Extension values X1–X5 chosen by the agent; review them |
| 1 | Build | Grassland grid, random biomass, linear growth, colour | G1–G4 | 2,500 cells, 2 m wide, +0.1 kg/step | `0996c0b` | — |
| 2 | Build | Lions and zebras, random walk via a parent species `animal` | A1, A2, A4, A5 | 20 + 20 agents, 1 m/step, none outside world | `c0f09f1` | Agent's own test script used a relative path and falsely reported a compile failure; the script was fixed, not the model |
| 3 | Build | Lions kill zebras within 3 m | A3 | lions stay 20, zebras 20 → 1 in 300 steps | `b1e9124` | — |
| 4 | Build | Parameters, map, population and biomass charts, monitors | O1–O5 | snapshots inspected; biomass +4,750 kg in 19 steps | `41148ab` | — |
| 5 | Compare | Line-by-line comparison with `savana_ca.gaml` | — | — | `353d9e8` | **Semantic error in AI code:** speed copied at creation, so the slider was ignored mid-run. Fixed, with a test that changes speed at cycle 5 |
| 6 | Extend | Zebras graze their cell, never below 0 kg | X1 | no grass, no lions: 1,275 cells reach exactly 0 kg | `373191e` | Test exposed the `update:` timing lag (also in hand-written model) |
| 7 | Fix | Biomass totals computed when read (`->`) | O4, O5 | step 0 now shows 74 kg eaten | `54b2abd` | — |
| 8 | Extend | Lion energy, move cost, gain, starvation; energy chart and parameters | X2–X6 | 1,010 energy at step 0 (20×49.5+20); 10 unfed lions die at step 100 | `b436024` | — |
| 9 | Report | Baseline 500-step run; draft report, this log | — | — | — | Report is a draft for the student to revise |

