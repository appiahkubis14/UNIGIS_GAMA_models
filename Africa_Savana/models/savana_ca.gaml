/**
* Name: savana_ca
* Description: A coupled Agent-Based Model (ABM) and Cellular Automaton (CA)
*              of the African Savannah.
*
*   AGENTS (ABM part)
*     - 20 lions  : wander randomly, drawn as orange circles (size 3).
*                   A lion kills every zebra it runs into.
*     - 20 zebras : wander randomly, drawn as grey triangles (size 2).
*
*   CELLS (CA part)
*     - A 50 x 50 grid of grassland cells covering the 100 m x 100 m world
*       (each cell is 2 m x 2 m).
*     - Each cell starts with a random biomass between 0 and 10 kg.
*     - Grass grows linearly: +0.1 kg per cell per time step.
*     - Cells are coloured from khaki (little grass) to dark green (lots of grass).
*
*   MODEL STRUCTURE (order required by the assignment)
*     1. global {}     -> parameters and initialisation
*     2. species {}    -> lion and zebra agents
*     3. grid {}       -> grassland cells (CA)
*     4. experiment {} -> GUI, displays and charts
*
* Author: samuel-appiah-kubi
* Tags: ABM, cellular automaton, predator-prey, savannah
*/

model savana_ca

// =====================================================================
// 1. GLOBAL: parameters and initialisation
// =====================================================================
global {

    // ---- Agent parameters ----
    int num_lions  <- 20;        // initial number of lions
    int num_zebras <- 20;        // initial number of zebras
    float lion_speed  <- 1.0;    // metres moved per time step
    float zebra_speed <- 1.0;    // metres moved per time step
    float kill_distance <- 3.0;  // a lion "runs into" a zebra within this distance (= lion size)

    // ---- Grass (CA) parameters ----
    float min_initial_biomass <- 0.0;   // kg per cell at start (lower bound)
    float max_initial_biomass <- 10.0;  // kg per cell at start (upper bound)
    float grass_growth_rate   <- 0.1;   // kg added per cell per time step (linear growth)
    float color_scale_max     <- 30.0;  // biomass at which a cell is drawn fully dark green

    // ---- Environment ----
    // The world is a 100 m x 100 m square; the grid below is laid over it.
    float world_size <- 100.0;
//    geometry shape <- square(world_size);

    // ---- Monitored values ----
    float total_biomass <- 0.0 update: sum(grassland collect each.biomass);
    float mean_biomass  <- 0.0 update: mean(grassland collect each.biomass);

    // ---- Initialisation ----
    // Agents are placed at random locations inside the world by default.
    // The grid cells are created automatically by GAMA (no 'create' needed).
    init {
        create lion  number: num_lions;
        create zebra number: num_zebras;
    }
}

// =====================================================================
// 2. SPECIES: the agents
// =====================================================================

// ---------------------------- LION ----------------------------------
species lion skills: [moving] {

    // Random walk: 'wander' turns by a random angle (up to +/- amplitude/2)
    // and moves forward; it automatically keeps the lion inside the world.
    reflex walk {
        do wander amplitude: 40.0 speed: lion_speed;
    }

    // Hunting: every zebra within kill_distance of this lion is killed.
    // 'die' is the built-in action that removes an agent from the simulation.
    reflex hunt {
        ask zebra at_distance kill_distance {
            do die;
        }
    }

    // Visualisation: orange circle of size 3
    aspect base {
        draw circle(3.0) color: #orange border: #black;
    }
}

// ---------------------------- ZEBRA ---------------------------------
species zebra skills: [moving] {

    // Random walk, same behaviour as the lion
    reflex walk {
        do wander amplitude: 40.0 speed: zebra_speed;
    }

    // Visualisation: grey triangle of size 2
    aspect base {
        draw triangle(2.0) color: #grey border: #black;
    }
}

// =====================================================================
// 3. GRID: the cellular automaton (grassland)
//    Placed after the species and before the experiment.
// =====================================================================
grid grassland width: 50 height: 50 neighbors: 4 {

    // Biomass of grass in this cell (kg), random between 0 and 10 at start
    float biomass <- rnd(min_initial_biomass, max_initial_biomass);

    // Cell colour depends on biomass:
    //   low biomass  -> khaki (dry grass)
    //   high biomass -> dark green (lush grass)
    // 'blend(c1, c2, r)' mixes r parts of c1 with (1 - r) parts of c2.
    // 'color' is the built-in grid attribute, so it is assigned, not redeclared.
    init {
        color <- blend(#darkgreen, #khaki, min(biomass / color_scale_max, 1.0));
    }

    // Linear grass growth: add a fixed amount every time step
    reflex grow {
        biomass <- biomass + grass_growth_rate;
        color <- blend(#darkgreen, #khaki, min(biomass / color_scale_max, 1.0));
    }
}

// =====================================================================
// 4. EXPERIMENT: user interface and outputs
// =====================================================================
experiment Savannah type: gui {

    // Sliders / input fields in the parameter panel
    parameter "Number of lions"      var: num_lions  min: 1 max: 200 category: "Agents";
    parameter "Number of zebras"     var: num_zebras min: 1 max: 200 category: "Agents";
    parameter "Lion speed (m/step)"  var: lion_speed  min: 0.1 max: 5.0 category: "Agents";
    parameter "Zebra speed (m/step)" var: zebra_speed min: 0.1 max: 5.0 category: "Agents";
    parameter "Grass growth (kg/step)" var: grass_growth_rate min: 0.0 max: 1.0 category: "Grass";

    output {

        // ---- Map view: grass underneath, animals on top ----
        display SavannahMap type: opengl {
            grid grassland;                     // the CA layer (cells use their 'color')
            species zebra aspect: base;
            species lion  aspect: base;
        }

        // ---- Population chart ----
        display Populations type: 2d refresh: every(1 #cycle) {
            chart "Animal populations" type: series {
                data "Lions"  value: length(lion)  color: #orange;
                data "Zebras" value: length(zebra) color: #grey;
            }
        }

        // ---- Grass chart ----
        display Grass type: 2d refresh: every(1 #cycle) {
            chart "Mean biomass per cell (kg)" type: series {
                data "Mean biomass" value: mean_biomass color: #green;
            }
        }

        // ---- Values shown in the monitor panel ----
        monitor "Lions"              value: length(lion);
        monitor "Zebras"             value: length(zebra);
        monitor "Total biomass (kg)" value: total_biomass with_precision 1;
        monitor "Mean biomass (kg)"  value: mean_biomass with_precision 2;
    }
}
