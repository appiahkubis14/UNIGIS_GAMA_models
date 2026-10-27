# Implementing the African Savannah model with an AI coding agent

Samuel Appiah-Kubi · GAMA 2025.6.4 · AI agent: Claude Code (Claude Opus 5.5)

## Introduction

In Unit 1 I hand-wrote a coupled agent-based / cellular-automaton (ABM–CA)
model of an African savannah (`savana_ca.gaml`). This exercise asks whether
an AI coding agent, given a written specification, can rebuild that model
feature by feature, and then extend it. I also check where the AI's output
is different from, better than, or wrong compared to my own code.

## Methods

**Specification** (written before the first prompt; full version with
requirement IDs in `docs/SPECIFICATION.md`):
100 m × 100 m world; 50 × 50 grassland grid, biomass U[0, 10] kg, +0.1 kg/step
linear growth, colour khaki → dark green (30 kg). 20 lions and 20 zebras
random-walk (`wander`, 40°, 1 m/step). A lion kills every zebra within 3 m
(its drawn size). Lions: orange circles, size 3; zebras: grey triangles,
size 2. GUI with parameters, population and biomass charts, monitors.
Structure: global → species → grid → experiment.
*Extension:* zebras eat ≤ 0.5 kg/step from their cell; lions start with
50 energy, lose 0.5 per step moved, gain 20 per zebra eaten, and die at ≤ 0.

**Procedure.** The agent implemented one feature at a time (grassland CA;
animals and random walk; hunting; experiment outputs; grazing; lion
energy). After each feature, the model was compiled with `gama-headless`
and run headless against small test models that checked the relevant
requirement (e.g. biomass +0.1 kg/step, energy book-keeping). Only then
was the feature committed (git history in `Africa_Savana_AI`). I then
compared the result line by line with my Unit 1 code (`docs/COMPARISON.md`).

## Results

All requirements were met after two corrections. The agent's code was
more parametrised (no magic numbers), traced every block to a requirement
ID, and avoided two editor warnings present in my version (redeclared
`color`, 3D displays for charts). Semantic errors found:

1. **AI only:** the first version copied lion/zebra speed into each agent at
   creation, so changing the speed slider during a run had no effect.
   Fixed by reading the global speed every step.
2. **Both versions:** biomass totals and cell colours used `update:`, which
   runs at the *start* of a step, so displays showed the previous step's
   grass. Found when grazing tests reported 0 kg eaten at step 0. Fixed in
   the AI version.

Baseline run of the extended model (seed 1, 500 steps): zebras fell from
20 to 2 by step 99. Lions that never ate starved at step 100 (20 → 10),
and the last lion died before step 300. Mean biomass rose from 5.1 to
54.7 kg/cell, because 2 zebras eat ≈ 1 kg/step while the grid regrows
250 kg/step.

## Discussion

A specification with numbered requirements made the agent's work checkable.
Most of the value came from executable tests, not from reading code: both
semantic errors only showed up in runs. The AI also made a plausible design
choice (a shared parent species) that broke a behaviour the specification did
not state explicitly. That argues for writing runtime behaviour, such as
"parameters can be changed during a run", into the specification. The
extended model is not a stable ecosystem: without reproduction, both
populations can only decline. Grass has no carrying capacity, so biomass
grows without bound. Adding reproduction and a logistic grass cap are the
natural next steps.
