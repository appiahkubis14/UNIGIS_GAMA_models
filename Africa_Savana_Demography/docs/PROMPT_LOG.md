# Prompt log: lion demography with lists

Tool: Claude Code (model: Claude Opus 5.5), GAMA 2025.6.4, 2026-10-29.
Base model: `Africa_Savana/models/savana_ca.gaml` (hand-written Savannah model).
Result: `models/savana_demography.gaml`, checked by `models/test_demography.gaml`.

## Prompt given to the agent

One prompt, the assignment brief pasted verbatim:

> Based on the Savannahs model, report demographic data of the lion
> population with help of lists, and keep a prompt log:
> • Declare a list of age values
> • In the initialisation, add the age of all lions to the list, in a reflex
> function add current and remove previous age values.
> • Each time step, report the number of values in the list, their minimum,
> mean and maximum values.
> • Update the colour of agents in different shades of red according to the
> mean age of the population
> • lions die if they are older than 60 years
> • just before an old lion dies, a baby lion is b

The last line was cut off; the agent read it as "a baby lion is born".

## Agent steps

| # | Step | What the agent did | Verification | Problems / choices |
|---|------|--------------------|--------------|--------------------|
| 1 | Explore | Read `savana_ca.gaml`, `savannah_ai.gaml` and `AI_LOG.md`; chose the hand-written model as the base and a new project folder like `Africa_Savana_AI` | — | — |
| 2 | Build | `list<int> lion_ages`; filled in global `init` with a `loop ... add`; global reflex `update_ages` asks each lion to `remove` its previous age, add 1 year, and `add` its current age | — | Assumed **1 step = 1 year** and initial ages `rnd(60)` (0–60); both are the agent's choice |
| 3 | Build | Global reflex `report_ages` writes n, min, mean, max to the console; same values in monitors and a `LionAges` chart | Console shows `n = 20` every step | Statistics use `->` so monitors always match the list |
| 4 | Build | Lion colour: `blend(#darkred, #pink, age / (2 × mean age))` | 19 distinct shades among 20 lions at cycle 130 | **Interpretation:** each lion is shaded by its age *relative to the population mean* (pink = young, red = mean, dark red ≥ 2 × mean). Alternative reading: all lions one shade set by the mean age |
| 5 | Build | Lion older than `max_lion_age` (60, parameter) creates a baby (age 0, same location, added to the list) and then dies | No lion over 60 in 131 steps; 41 births; population stays 20 | Colours updated after all ages, since they depend on the new mean |
| 6 | Test | `test_demography.gaml` compares the list with the real lion ages every step | Headless, seed 1.0, 131 steps: `errors=0` | First version wrote the report in `init` too, giving two "Cycle 0" lines; removed |
| 7 | Fix | `total_biomass` / `mean_biomass` changed from `update:` to `->` | Nil-value error at end of headless run gone | Error also occurs in the original `savana_ca.gaml` (headless, 5 steps) |
| 8 | Output | Snapshots at cycle 149 in `docs/figures/` | Inspected | — |

## Observations

- With one baby per death, the population is constant (20) and every lion
  is replaced once every 61 years, so the age statistics repeat with a
  61-step period (see `docs/figures/lion_ages_cycle_149.png`). Mean age
  stays between ≈ 25 and 38 years; maximum between 54 and 60.
- Lions still kill zebras on contact (unchanged), so zebras are almost
  gone after 150 steps; this does not affect lion demography because
  lions have no energy in the base model.
