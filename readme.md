# GAMA Models Collection

This repository contains a small set of agent-based and cellular automaton simulations built with the [GAMA Platform](https://gama-platform.org/). The project demonstrates several core ideas in multi-agent simulation, including predator-prey dynamics, spatial modelling, simple 3D physics, and basic pattern generation.

The models were created as learning and experimentation files using GAMA's `.gaml` language and can be opened directly in the GAMA application.

## Project overview

The workspace includes two main model groups:

- `Africa_Savana/`: Savannah ecosystem simulations.
- `Hello World/`: Simple agent movement and a 3D particle simulation.

## Included models

### 1. Africa_Savana / savana.gaml
A simple predator-prey simulation featuring:

- lions and zebras as moving agents
- random wandering behaviour
- lions hunting zebras when within a fixed distance
- a graphical display showing population counts

This model introduces the basics of agent movement, interaction rules, and GUI output in GAMA.

### 2. Africa_Savana / savana_ca.gaml
An extended savannah model combining agent-based and cellular automata concepts:

- lion and zebra agents
- random motion and predator-prey interaction
- a `grassland` grid representing biomass across a landscape
- grass growth over time
- charts for animal populations and mean biomass
- monitoring values such as total and mean biomass

This is the most complete ecological model in the repository and shows how ABM and CA can be combined in a single simulation.

### 3. Hello World / Hello_world.gaml
A minimal GAML example that demonstrates:

- creating a population of agents
- moving them with the built-in `moving` skill
- random wandering behaviour
- displaying the agents in a map window

This serves as an introductory model for learning GAMA syntax and simulation structure.

### 4. Hello World / dem.gaml
A 3D particle system simulation implementing:

- gravity and damping
- collisions with walls
- particle-to-particle collisions
- energy and average speed tracking
- motion trails and an overlay HUD
- 3D rendering in an OpenGL display

This model is a good example of custom physics logic in GAMA and shows how to model dynamic objects beyond simple agents.

## Repository structure

```text
Gama_Workspace/
├── Africa_Savana/
│   ├── includes/
│   ├── models/
│   │   ├── savana.gaml
│   │   ├── savana_ca.gaml
│   │   └── snapshots/
│   └── ...
├── Hello World/
│   ├── includes/
│   ├── models/
│   │   ├── Hello_world.gaml
│   │   ├── dem.gaml
│   │   └── snapshots/
│   └── ...
├── readme.md
└── .gitignore
```

## Requirements

To run these models, you need:

- the GAMA Platform installed on your machine
- a GAMA project workspace or imported model folder
- optionally, a graphics-capable machine for OpenGL 3D views

GAMA is the environment used to interpret and execute the `.gaml` simulation files.

## How to run the models

1. Install and launch the GAMA Platform.
2. Open the project folder in GAMA or import the workspace directory.
3. Open one of the `.gaml` files in the `models/` directories.
4. Select the experiment you want to run (for example `Savannah`, `DEM_3D`, or `maain_experiment`).
5. Press the run button to start the simulation.

### Example model launch flow

- For the savannah ecosystem: open `Africa_Savana/models/savana_ca.gaml`
- For the simple agent demo: open `Hello World/models/Hello_world.gaml`
- For the 3D particle physics demo: open `Hello World/models/dem.gaml`

## Key parameters you can tune

Depending on the model, parameters include:

- number of agents or particles
- movement speed
- world size
- grass growth rate
- gravity and damping
- restitution coefficient
- display options such as trails and overlays

These are exposed in the experiments as editable sliders and controls inside the GAMA GUI.

## Learning value

This project is useful for understanding:

- agent-based modelling
- cellular automata
- simple ecological systems
- spatial simulation and movement behaviours
- GUI experimentation in GAMA
- custom physics logic in 3D environments

## Notes

- The project appears to be intended for academic and educational use.
- Snapshot images in each `models/snapshots/` folder provide examples of simulation output.
- Model naming and structure vary slightly between files, reflecting experimentation and incremental learning.

## Author

This project was authored by Samuel Appiah-Kubi.

## Summary

This repository demonstrates a diverse set of GAMA-based simulations, ranging from a simple ecological model to a 3D particle system. It is a practical example of how agent-based systems can model movement, interaction, environmental change, and visual behaviour in a programmable simulation environment.
