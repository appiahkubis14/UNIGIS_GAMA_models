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

	// ---- Animals (A1, A2) ----
	int nb_lions <- 20;
	int nb_zebras <- 20;
	float lion_speed <- 1.0;    // m per step
	float zebra_speed <- 1.0;   // m per step
	float wander_amplitude <- 40.0;  // max heading change per step (degrees)
	float kill_distance <- 3.0;      // A3: a lion "runs into" a zebra within its drawn size

	// ---- Grass (G2, G3, G4) ----
	float initial_biomass_min <- 0.0;   // kg
	float initial_biomass_max <- 10.0;  // kg
	float grass_growth_rate <- 0.1;     // kg per cell per step
	float biomass_full_colour <- 30.0;  // kg at which a cell is fully dark green

	// ---- Monitored values (O4, O5) ----
	float total_biomass <- 0.0 update: sum(grassland collect each.biomass);
	float mean_biomass <- 0.0 update: total_biomass / length(grassland);

	// E1: the default GAMA world is already 100 m x 100 m, so 'shape' is not redefined.

	// A1: random initial locations are GAMA's default for 'create'.
	init {
		create lion number: nb_lions;
		create zebra number: nb_zebras;
	}
}

// =====================================================================
// SPECIES
// =====================================================================

// A2: random walk; 'wander' keeps agents inside the world.
// The speed is read from the global every step so that changing the
// parameter during a run affects agents that already exist.
species lion skills: [moving] {

	reflex walk {
		do wander amplitude: wander_amplitude speed: lion_speed;
	}

	// A3: every zebra the lion runs into is killed in the same step.
	reflex hunt {
		ask zebra at_distance kill_distance {
			do die;
		}
	}

	aspect base {  // A4
		draw circle(3.0) color: #orange border: #black;
	}
}

species zebra skills: [moving] {

	reflex walk {
		do wander amplitude: wander_amplitude speed: zebra_speed;
	}

	aspect base {  // A4
		draw triangle(2.0) color: #grey border: #black;
	}
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

	// O1
	parameter "Number of lions" var: nb_lions min: 1 max: 200 category: "Animals";
	parameter "Number of zebras" var: nb_zebras min: 1 max: 200 category: "Animals";
	parameter "Lion speed (m/step)" var: lion_speed min: 0.1 max: 5.0 category: "Animals";
	parameter "Zebra speed (m/step)" var: zebra_speed min: 0.1 max: 5.0 category: "Animals";
	parameter "Grass growth (kg/step)" var: grass_growth_rate min: 0.0 max: 1.0 category: "Grass";

	output {
		// O2: grass below, zebras, lions on top
		display SavannahMap type: opengl {
			grid grassland;
			species zebra aspect: base;
			species lion aspect: base;
		}

		// O3
		display Populations type: 2d {
			chart "Animal populations" type: series {
				data "Lions" value: length(lion) color: #orange;
				data "Zebras" value: length(zebra) color: #grey;
			}
		}

		// O4
		display Grass type: 2d {
			chart "Mean biomass per cell (kg)" type: series {
				data "Mean biomass" value: mean_biomass color: #darkgreen;
			}
		}

		// O5
		monitor "Lions" value: length(lion);
		monitor "Zebras" value: length(zebra);
		monitor "Total biomass (kg)" value: total_biomass with_precision 1;
		monitor "Mean biomass (kg)" value: mean_biomass with_precision 2;
	}
}
