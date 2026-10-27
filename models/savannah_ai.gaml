/**
* Name: savannah_ai
* Description: African Savannah – agent-based lions and zebras on a
*              grassland cellular automaton, implemented with an AI agent
*              from docs/SPECIFICATION.md (requirement IDs in comments).
* Author: samuel-appiah-kubi (with Claude Code)
* Tags: ABM, cellular automaton, predator-prey, savannah
*/

model savannah_ai

// =====================================================================
// GLOBAL
// =====================================================================
global {

	// ---- Grass (G2, G3, G4) ----
	float initial_biomass_min <- 0.0;   // kg
	float initial_biomass_max <- 10.0;  // kg
	float grass_growth_rate <- 0.1;     // kg per cell per step
	float biomass_full_colour <- 30.0;  // kg at which a cell is fully dark green

	// E1: the default GAMA world is already 100 m x 100 m, so 'shape' is not redefined.
}

// =====================================================================
// GRID (G1–G4)
// =====================================================================
grid grassland width: 50 height: 50 neighbors: 4 {

	float biomass <- rnd(initial_biomass_min, initial_biomass_max);  // G2

	// G4: khaki at 0 kg -> dark green at biomass_full_colour.
	// 'color' is the built-in grid attribute, so it is assigned, not redeclared.
	action update_colour {
		color <- blend(#darkgreen, #khaki, min(biomass / biomass_full_colour, 1.0));
	}

	init {
		do update_colour;
	}

	// G3: linear growth
	reflex grow {
		biomass <- biomass + grass_growth_rate;
		do update_colour;
	}
}

// =====================================================================
// EXPERIMENT
// =====================================================================
experiment Savannah type: gui {
	output {
		display SavannahMap type: opengl {
			grid grassland;
		}
	}
}
