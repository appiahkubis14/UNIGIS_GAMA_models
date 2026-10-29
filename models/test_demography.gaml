/**
* Name: test_demography
* Description: Headless check for savana_demography.gaml. Every step it checks
*              that the list of ages holds exactly the ages of the living
*              lions and that no lion is older than max_lion_age. At cycle 130
*              it prints the population, number of errors, number of distinct
*              colours and number of births.
* Author: samuel-appiah-kubi (with Claude Code)
*/

model test_demography

import "savana_demography.gaml"

global {
    int errors <- 0;
    int births <- 0;

    // Newborns are the only lions of age 0 at the end of the global reflexes
    reflex count_births {
        births <- births + (lion_ages count (each = 0));
    }

    reflex check {
        list<int> real_ages <- lion collect each.age;
        if (length(real_ages) != length(lion_ages)) or ((real_ages sort_by each) != (lion_ages sort_by each)) {
            errors <- errors + 1;
            write "MISMATCH at cycle " + cycle;
        }
        if (real_ages one_matches (each > max_lion_age)) {
            errors <- errors + 1;
            write "TOO OLD at cycle " + cycle;
        }
        if (cycle = 130) {
            write "RESULT lions=" + length(lion) + " errors=" + errors
                + " colours=" + length(remove_duplicates(lion collect each.colour))
                + " births=" + births;
        }
    }
}

experiment t type: gui {}
