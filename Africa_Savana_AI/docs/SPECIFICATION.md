# Specification – African Savannah (ABM + CA)

Written before the first prompt to the AI agent. It describes the Unit 1
model (lions, zebras, grassland cellular automaton) and, separately, the
extension built in step 4. The AI implementation in `models/savannah_ai.gaml`
must satisfy every numbered requirement; the IDs are referenced in commits,
in the comparison and in the AI log.

## 1. Purpose

Couple an agent-based model (lions and zebras) with a cellular automaton
(grassland) to observe predator–prey and grass dynamics on a savannah.

## 2. Environment

| ID  | Requirement |
|-----|-------------|
| E1  | The world is a square of 100 m × 100 m (GAMA default world). |
| E2  | One simulation step = one cycle; no other time unit is used. |

## 3. Grassland (cellular automaton)

| ID  | Requirement |
|-----|-------------|
| G1  | A grid `grassland` of 50 × 50 cells covers the world (each cell 2 m × 2 m), von Neumann neighbourhood (4). |
| G2  | Each cell has `biomass` (kg), initialised uniformly at random in [0, 10]. |
| G3  | Grass grows linearly: every step each cell gains +0.1 kg. No upper bound in Unit 1. |
| G4  | Cell colour is a linear blend from khaki (0 kg) to dark green (≥ 30 kg), reflecting the current biomass. |

## 4. Agents

| ID  | Requirement |
|-----|-------------|
| A1  | 20 lions and 20 zebras are created at random locations at initialisation. |
| A2  | Lions and zebras move by random walk (`wander`, heading change ≤ 40°), speed 1 m/step, staying inside the world. |
| A3  | A lion kills every zebra it "runs into": any zebra within 3 m (the lion's drawn size) is removed in the same step. |
| A4  | Lions are drawn as orange circles of size 3; zebras as grey triangles of size 2. |
| A5  | No reproduction and no natural death in Unit 1: the lion count stays constant, the zebra count only decreases. |

## 5. Experiment / outputs

| ID  | Requirement |
|-----|-------------|
| O1  | GUI experiment `Savannah` with parameters: number of lions, number of zebras (1–200), lion/zebra speed (0.1–5), grass growth rate (0–1). |
| O2  | Map display: grass layer below, zebras, lions on top. |
| O3  | Time-series chart of lion and zebra counts. |
| O4  | Time-series chart of mean biomass per cell. |
| O5  | Monitors: number of lions, number of zebras, total biomass, mean biomass. |

## 6. Model structure

| ID  | Requirement |
|-----|-------------|
| S1  | Sections appear in the order `global` → `species` → `grid` → `experiment`. |
| S2  | All numeric constants above are global variables (no magic numbers in behaviour). |

## 7. Extension (step 4)

| ID  | Requirement |
|-----|-------------|
| X1  | Zebras eat grass: each step a zebra removes up to 0.5 kg from the cell it stands on (never driving biomass below 0). |
| X2  | Lions have `energy`, starting at 50. |
| X3  | A lion loses 0.5 energy per step of movement. |
| X4  | A lion gains 20 energy per zebra eaten (X4 replaces A3's "kill" with "eat"). |
| X5  | A lion with energy ≤ 0 dies. |
| X6  | A chart shows mean lion energy; lion energy and grass consumption rates are experiment parameters. |

Values in X1–X6 are modelling choices made for this assignment, not
empirical data.
