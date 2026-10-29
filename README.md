# Africa Savana

Agent-based savannah ecosystem models in GAMA.

| Model | Description | Experiment |
|-------|-------------|------------|
| `models/savana.gaml` | Lions and zebras wander randomly; a lion kills every zebra within a fixed distance; population counts are displayed. | `Savannah` |
| `models/savana_ca.gaml` | The same agents on a 50 × 50 grassland cellular automaton: random initial biomass (0–10 kg), linear grass growth, population and biomass charts and monitors. | `Savannah` |

Example output is in `models/snapshots/`.

## How to run

1. Install the [GAMA Platform](https://gama-platform.org/) (tested with GAMA 2025.6.4).
2. Clone this branch: `git clone -b africa-savana --single-branch https://github.com/appiahkubis14/UNIGIS_GAMA_models.git Africa_Savana`
3. In GAMA, use *File → Import → Existing Projects into Workspace* and select the cloned folder.
4. Open the model in `models/` and run the experiment named above.

This branch holds one project of the [UNIGIS_GAMA_models](https://github.com/appiahkubis14/UNIGIS_GAMA_models) collection; `main` has all projects together. Commit hashes mentioned in the docs refer to `main`.

## Author

Samuel Appiah-Kubi
