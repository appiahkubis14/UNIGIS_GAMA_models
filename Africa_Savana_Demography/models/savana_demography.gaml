/**
* Name: savana_demography
* Description: The Savannah model (savana_ca.gaml) extended with demographic
*              reporting of the lion population using a list of ages.
*
*   DEMOGRAPHY
*     - One time step = one year.
*     - Each lion has an age (years), random between 0 and 60 at start.
*     - A global list 'lion_ages' holds the age of every living lion:
*         * filled in the global init with the age of all lions;
*         * updated every step in a reflex: each lion removes its previous
*           age from the list and adds its current age.
*     - Every step the number of values, the minimum, mean and maximum age
*       are reported (console, monitors and a chart).
*     - Lions are drawn in shades of red according to their age compared
*       with the mean age of the population: light red = much younger than
*       the mean, red = at the mean, dark red = twice the mean or older.
*     - A lion older than 60 years dies; just before it dies it gives birth
*       to a baby lion (age 0) at its location, so the population stays
*       constant.
*
*   Everything else (zebras, hunting, grassland CA) is unchanged from
*   savana_ca.gaml.
*
* Author: samuel-appiah-kubi (with Claude Code)
* Tags: ABM, cellular automaton, predator-prey, savannah, demography, lists
*/

model savana_demography

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

    // ---- Demography parameters ----
    int max_lion_age <- 60;      // years; a lion older than this dies

    // ---- Grass (CA) parameters ----
    float min_initial_biomass <- 0.0;   // kg per cell at start (lower bound)
    float max_initial_biomass <- 10.0;  // kg per cell at start (upper bound)
    float grass_growth_rate   <- 0.1;   // kg added per cell per time step (linear growth)
    float color_scale_max     <- 30.0;  // biomass at which a cell is drawn fully dark green

    // ---- Monitored values ----
    // Computed when read (->), as in savannah_ai.gaml: 'update:' failed with a
    // nil error when the headless run ended.
    float total_biomass -> sum(grassland collect each.biomass);
    float mean_biomass  -> mean(grassland collect each.biomass);

    // ---- Demographic data ----
    // The list of ages: one value per living lion.
    list<int> lion_ages <- [];

    // Statistics of the list (computed when read, so they always match it)
    int nb_ages    -> length(lion_ages);
    int min_age    -> empty(lion_ages) ? 0 : min(lion_ages);
    float mean_age -> empty(lion_ages) ? 0.0 : mean(lion_ages);
    int max_age    -> empty(lion_ages) ? 0 : max(lion_ages);

    // ---- Initialisation ----
    init {
        create lion  number: num_lions;
        create zebra number: num_zebras;

        // Add the age of all lions to the list
        loop l over: lion {
            add l.age to: lion_ages;
        }
        ask lion { do update_colour; }
    }

    // Global reflexes run before the species reflexes, in the order written.
    // 1) Every lion grows one year older: it removes its previous age from
    //    the list and adds its current one (or dies of old age).
    reflex update_ages {
        ask lion {
            do grow_old;
        }
        // Colours depend on the new mean, so they are set once all ages are updated
        ask lion { do update_colour; }
    }

    // 2) Report the demographic data of this time step
    reflex report_ages {
        write "Cycle " + cycle + " | lion ages: n = " + nb_ages
            + ", min = " + min_age
            + ", mean = " + (mean_age with_precision 2)
            + ", max = " + max_age;
    }
}

// =====================================================================
// 2. SPECIES: the agents
// =====================================================================

// ---------------------------- LION ----------------------------------
species lion skills: [moving] {

    int age <- rnd(max_lion_age);   // years, random between 0 and 60 at start
    rgb colour <- #red;

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

    // Called once per step by the global reflex 'update_ages'.
    action grow_old {
        remove age from: lion_ages;     // remove the previous age value
        age <- age + 1;
        if (age > max_lion_age) {
            // Just before the old lion dies, a baby lion is born at its place
            create lion {
                age <- 0;
                location <- myself.location;
                add age to: lion_ages;
            }
            do die;
        } else {
            add age to: lion_ages;      // add the current age value
        }
    }

    // Shade of red from the lion's age relative to the mean age:
    //   0 years -> light red (pink), mean age -> mid red, 2 x mean -> dark red.
    // 'blend(c1, c2, r)' mixes r parts of c1 with (1 - r) parts of c2.
    action update_colour {
        float ratio <- mean_age = 0 ? 0.0 : min(age / (2 * mean_age), 1.0);
        colour <- blend(#darkred, #pink, ratio);
    }

    // Visualisation: circle of size 3 in the lion's shade of red
    aspect base {
        draw circle(3.0) color: colour border: #black;
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
// =====================================================================
grid grassland width: 50 height: 50 neighbors: 4 {

    // Biomass of grass in this cell (kg), random between 0 and 10 at start
    float biomass <- rnd(min_initial_biomass, max_initial_biomass);

    // Cell colour: khaki (little grass) -> dark green (lots of grass)
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

    parameter "Number of lions"      var: num_lions  min: 1 max: 200 category: "Agents";
    parameter "Number of zebras"     var: num_zebras min: 1 max: 200 category: "Agents";
    parameter "Lion speed (m/step)"  var: lion_speed  min: 0.1 max: 5.0 category: "Agents";
    parameter "Zebra speed (m/step)" var: zebra_speed min: 0.1 max: 5.0 category: "Agents";
    parameter "Maximum lion age (years)" var: max_lion_age min: 1 max: 100 category: "Demography";
    parameter "Grass growth (kg/step)" var: grass_growth_rate min: 0.0 max: 1.0 category: "Grass";

    output {

        // ---- Map view: grass underneath, animals on top ----
        display SavannahMap type: opengl {
            grid grassland;
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

        // ---- Lion age chart (from the list of ages) ----
        display LionAges type: 2d refresh: every(1 #cycle) {
            chart "Lion ages (years)" type: series {
                data "Minimum" value: min_age  color: #pink;
                data "Mean"    value: mean_age color: #red;
                data "Maximum" value: max_age  color: #darkred;
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
        monitor "Ages in list"       value: nb_ages;
        monitor "Minimum age"        value: min_age;
        monitor "Mean age"           value: mean_age with_precision 2;
        monitor "Maximum age"        value: max_age;
        monitor "Total biomass (kg)" value: total_biomass with_precision 1;
        monitor "Mean biomass (kg)"  value: mean_biomass with_precision 2;
    }
}
