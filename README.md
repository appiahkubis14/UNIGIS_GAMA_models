# Hello World

Introductory GAMA models.

| Model | Description | Experiment |
|-------|-------------|------------|
| `models/Hello_world.gaml` | A population of agents wandering with the `moving` skill, shown on a map. | `maain_experiment` |
| `models/dem.gaml` | 3D particle system: gravity, damping, wall and particle collisions, energy and speed tracking, trails and a HUD in an OpenGL display. | `DEM_3D` |

Example output is in `models/snapshots/`.

## How to run

1. Install the [GAMA Platform](https://gama-platform.org/) (tested with GAMA 2025.6.4).
2. Clone this branch: `git clone -b hello-world --single-branch https://github.com/appiahkubis14/UNIGIS_GAMA_models.git Hello_World`
3. In GAMA, use *File → Import → Existing Projects into Workspace* and select the cloned folder.
4. Open the model in `models/` and run the experiment named above.

This branch holds one project of the [UNIGIS_GAMA_models](https://github.com/appiahkubis14/UNIGIS_GAMA_models) collection; `main` has all projects together. Commit hashes mentioned in the docs refer to `main`.

## Author

Samuel Appiah-Kubi
