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

	// ---- Lion energy (X2-X5) ----
	float lion_initial_energy <- 50.0;
	float lion_move_cost <- 0.5;     // energy lost per step of movement
	float lion_energy_gain <- 20.0;  // energy gained per zebra eaten

	// ---- Grass (G2, G3, G4) ----
	float initial_biomass_min <- 0.0;   // kg
	float initial_biomass_max <- 10.0;  // kg
	float grass_growth_rate <- 0.1;     // kg per cell per step
	float biomass_full_colour <- 30.0;  // kg at which a cell is fully dark green
	float zebra_grazing <- 0.5;         // X1: kg a zebra eats per step from its cell

	// ---- Monitored values (O4, O5) ----
	// Computed when read (->), not with 'update:', which runs at the start of
	// the step and would show the biomass from before grazing and growth.
	float total_biomass -> sum(grassland collect each.biomass);
	float mean_biomass -> total_biomass / length(grassland);

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
	float energy <- lion_initial_energy;  // X2

	reflex walk {
		do wander amplitude: wander_amplitude speed: lion_speed;
		energy <- energy - lion_move_cost;  // X3
	}

	// A3 / X4: every zebra the lion runs into is eaten in the same step.
	reflex hunt {
		list<zebra> prey <- zebra at_distance kill_distance;
		energy <- energy + lion_energy_gain * length(prey);
		ask prey {
			do die;
		}
	}

	// X5: runs after 'hunt', so a lion that eats in its last step survives.
	reflex starve when: energy <= 0 {
		do die;
	}

	aspect base {  // A4
		draw circle(3.0) color: #orange border: #black;
	}
}

species zebra skills: [moving] {

	reflex walk {
		do wander amplitude: wander_amplitude speed: zebra_speed;
	}

	// X1: eat from the cell under the zebra, never below 0 kg.
	reflex graze {
		grassland cell <- grassland(location);
		cell.biomass <- cell.biomass - min(zebra_grazing, cell.biomass);
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
	parameter "Zebra grazing (kg/step)" var: zebra_grazing min: 0.0 max: 5.0 category: "Grass";  // X6
	parameter "Lion initial energy" var: lion_initial_energy min: 1.0 max: 200.0 category: "Lion energy";  // X6
	parameter "Lion move cost (per step)" var: lion_move_cost min: 0.0 max: 5.0 category: "Lion energy";
	parameter "Lion gain per zebra" var: lion_energy_gain min: 0.0 max: 100.0 category: "Lion energy";

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

		// X6
		display LionEnergy type: 2d {
			chart "Mean lion energy" type: series {
				data "Mean energy" value: empty(lion) ? 0.0 : mean(lion collect each.energy) color: #orange;
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
		monitor "Mean lion energy" value: empty(lion) ? 0.0 : mean(lion collect each.energy) with_precision 1;
		monitor "Total biomass (kg)" value: total_biomass with_precision 1;
		monitor "Mean biomass (kg)" value: mean_biomass with_precision 2;
	}
}
