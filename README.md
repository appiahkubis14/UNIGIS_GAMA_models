# Africa Savana Demography

The savannah model extended with demographic data for the lion population, kept in a GAML list.

- A list holds the age of every living lion: filled at initialisation, then each step every lion removes its previous age and adds its current one.
- Each step the number of values, minimum, mean and maximum age are reported (console, monitors and chart).
- Lions are shaded red by their age relative to the mean age (pink = young, dark red = twice the mean or older).
- Lions older than 60 years die; just before dying, each gives birth to a baby lion.

| File | Purpose |
|------|---------|
| `models/savana_demography.gaml` | The model (experiment `Savannah`). One step = one year. |
| `models/test_demography.gaml` | Headless check that the list always matches the living lions. |
| `docs/PROMPT_LOG.md` | Prompt log of the AI-assisted development. |
| `docs/figures/` | Map and lion-age chart at step 149. |

## How to run

1. Install the [GAMA Platform](https://gama-platform.org/) (tested with GAMA 2025.6.4).
2. Clone this branch: `git clone -b africa-savana-demography --single-branch https://github.com/appiahkubis14/UNIGIS_GAMA_models.git Africa_Savana_Demography`
3. In GAMA, use *File → Import → Existing Projects into Workspace* and select the cloned folder.
4. Open the model in `models/` and run the experiment named above.

This branch holds one project of the [UNIGIS_GAMA_models](https://github.com/appiahkubis14/UNIGIS_GAMA_models) collection; `main` has all projects together. Commit hashes mentioned in the docs refer to `main`.

## Author

Samuel Appiah-Kubi
