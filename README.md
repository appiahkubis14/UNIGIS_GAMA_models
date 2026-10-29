# Africa Savana AI

The savannah model (lions, zebras and a grassland cellular automaton) rebuilt with an AI coding agent (Claude Code) from a written specification, then compared with the hand-written model and extended.

- `models/savannah_ai.gaml`: the model. Comments carry the requirement IDs from the specification. Extensions: zebras graze their cell; lions have energy, pay a cost to move, gain energy from zebras and starve at 0.
- `docs/SPECIFICATION.md`: requirements (G, A, O, X IDs).
- `docs/AI_LOG.md`: prompts and agent steps, with verification for each feature.
- `docs/COMPARISON.md`: comparison with the hand-written `savana_ca.gaml`.
- `docs/REPORT.md`: report draft.

Experiment: `Savannah`.

## How to run

1. Install the [GAMA Platform](https://gama-platform.org/) (tested with GAMA 2025.6.4).
2. Clone this branch: `git clone -b africa-savana-ai --single-branch https://github.com/appiahkubis14/UNIGIS_GAMA_models.git Africa_Savana_AI`
3. In GAMA, use *File → Import → Existing Projects into Workspace* and select the cloned folder.
4. Open the model in `models/` and run the experiment named above.

This branch holds one project of the [UNIGIS_GAMA_models](https://github.com/appiahkubis14/UNIGIS_GAMA_models) collection; `main` has all projects together. Commit hashes mentioned in the docs refer to `main`.

## Author

Samuel Appiah-Kubi
