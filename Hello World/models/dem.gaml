model Advanced3D_DEM

global {
    // ==================== SIMULATION PARAMETERS ====================
    int num_particles <- 300;
    float gravity <- -9.81;
    float dt <- 0.01;              // was 0.001: with one step per cycle that was almost frozen
    float world_size <- 50.0;
    float restitution <- 0.6;
    float friction_coef <- 0.3;
    float damping <- 0.02;

    float min_radius <- 0.5;
    float max_radius <- 1.5;
    float wall_height <- 30.0;

    bool show_trails <- true;
    int trail_length <- 8;

    float total_kinetic_energy <- 0.0;
    float avg_speed <- 0.0;
    int collision_count <- 0;

    // World spans [0, world_size] in x and y (GAMA does not allow negative world coordinates)
    geometry shape <- square(world_size);

    // ==================== INITIALIZATION ====================
    init {
        create particle number: num_particles {
            radius <- rnd(min_radius, max_radius);
            mass <- 4.0 / 3.0 * #pi * radius ^ 3 * 1000.0;
            px <- rnd(radius, world_size - radius);
            py <- rnd(radius, world_size - radius);
            pz <- rnd(radius, wall_height * 0.7);
            vx <- rnd(-2.0, 2.0);
            vy <- rnd(-2.0, 2.0);
            vz <- rnd(-2.0, 2.0);
            fx <- 0.0;
            fy <- 0.0;
            fz <- 0.0;
            pcolor <- rgb(rnd(80, 255), rnd(80, 255), rnd(80, 255));
            trail <- [];
            location <- {px, py, pz};
        }
    }

    // ==================== MAIN PHYSICS LOOP ====================
    reflex update_dynamics {

        // --- Step 1: Integrate all particles ---
        ask particle {
            // Gravity
            fz <- fz + gravity * mass;

            // Air damping
            fx <- fx - vx * damping * mass;
            fy <- fy - vy * damping * mass;
            fz <- fz - vz * damping * mass;

            // Semi-implicit Euler velocity update
            vx <- vx + (fx / mass) * dt;
            vy <- vy + (fy / mass) * dt;
            vz <- vz + (fz / mass) * dt;

            // Predict new position
            float nx <- px + vx * dt;
            float ny <- py + vy * dt;
            float nz <- pz + vz * dt;
            float r <- radius;

            // Floor collision
            if (nz - r < 0.0) {
                nz <- r;
                vz <- -vz * restitution;
                vx <- vx * (1.0 - friction_coef);
                vy <- vy * (1.0 - friction_coef);
            }

            // Ceiling collision
            if (nz + r > wall_height) {
                nz <- wall_height - r;
                vz <- -vz * restitution;
            }

            // X wall collisions
            if (nx - r < 0.0) {
                nx <- r;
                vx <- -vx * restitution;
            }
            if (nx + r > world_size) {
                nx <- world_size - r;
                vx <- -vx * restitution;
            }

            // Y wall collisions
            if (ny - r < 0.0) {
                ny <- r;
                vy <- -vy * restitution;
            }
            if (ny + r > world_size) {
                ny <- world_size - r;
                vy <- -vy * restitution;
            }

            // Commit position
            px <- nx;
            py <- ny;
            pz <- nz;

            // Reset force accumulator
            fx <- 0.0;
            fy <- 0.0;
            fz <- 0.0;
        }

        // --- Step 2: Pairwise collision detection and response ---
        list<particle> all_parts <- list(particle);
        int n <- length(all_parts);

        loop i from: 0 to: n - 2 {
            particle p1 <- all_parts[i];
            loop j from: i + 1 to: n - 1 {
                particle p2 <- all_parts[j];

                float dx <- p2.px - p1.px;
                float dy <- p2.py - p1.py;
                float dz <- p2.pz - p1.pz;
                float dist_sq <- dx * dx + dy * dy + dz * dz;
                float min_dist <- p1.radius + p2.radius;

                if (dist_sq < min_dist * min_dist and dist_sq > 0.0001) {
                    float dist <- sqrt(dist_sq);
                    float cnx <- dx / dist;
                    float cny <- dy / dist;
                    float cnz <- dz / dist;

                    // Positional correction (full overlap, split by mass)
                    float overlap <- min_dist - dist;
                    float total_mass <- p1.mass + p2.mass;
                    float w1 <- overlap * (p2.mass / total_mass);
                    float w2 <- overlap * (p1.mass / total_mass);

                    p1.px <- p1.px - cnx * w1;
                    p1.py <- p1.py - cny * w1;
                    p1.pz <- p1.pz - cnz * w1;
                    p2.px <- p2.px + cnx * w2;
                    p2.py <- p2.py + cny * w2;
                    p2.pz <- p2.pz + cnz * w2;

                    // Relative velocity along normal
                    float rvx <- p2.vx - p1.vx;
                    float rvy <- p2.vy - p1.vy;
                    float rvz <- p2.vz - p1.vz;
                    float vn <- rvx * cnx + rvy * cny + rvz * cnz;

                    // Resolve only if approaching
                    if (vn < 0.0) {
                        float imp <- -(1.0 + restitution) * vn / (1.0 / p1.mass + 1.0 / p2.mass);

                        p1.vx <- p1.vx - imp * cnx / p1.mass;
                        p1.vy <- p1.vy - imp * cny / p1.mass;
                        p1.vz <- p1.vz - imp * cnz / p1.mass;
                        p2.vx <- p2.vx + imp * cnx / p2.mass;
                        p2.vy <- p2.vy + imp * cny / p2.mass;
                        p2.vz <- p2.vz + imp * cnz / p2.mass;

                        collision_count <- collision_count + 1;
                    }
                }
            }
        }

        // --- Step 3: Sync GAMA location (after collision correction) and update trails ---
        ask particle {
            location <- {px, py, pz};
            if (show_trails) {
                trail << {px, py, pz};
                if (length(trail) > trail_length) {
                    remove index: 0 from: trail;
                }
            } else if (!empty(trail)) {
                trail <- [];
            }
        }

        // --- Step 4: Statistics ---
        total_kinetic_energy <- sum(particle collect (0.5 * each.mass * (each.vx ^ 2 + each.vy ^ 2 + each.vz ^ 2)));
        avg_speed <- n > 0 ? mean(particle collect sqrt(each.vx ^ 2 + each.vy ^ 2 + each.vz ^ 2)) : 0.0;
    }
}

// ==================== PARTICLE SPECIES ====================
species particle {
    float radius;
    float mass;
    float px;
    float py;
    float pz;
    float vx;
    float vy;
    float vz;
    float fx;
    float fy;
    float fz;
    rgb pcolor;
    list<point> trail <- [];

    aspect default {
        draw sphere(radius) color: pcolor at: {px, py, pz};
    }
}

// ==================== EXPERIMENT ====================
experiment DEM_3D type: gui {
    parameter "Number of particles" var: num_particles min: 1 max: 2000;
    parameter "Coefficient of restitution" var: restitution min: 0.0 max: 1.0;
    parameter "Gravity" var: gravity;
    parameter "Damping" var: damping min: 0.0 max: 1.0;
    parameter "Show trails" var: show_trails;

    output {
        display View3D type: opengl background: rgb(5, 5, 16) axes: false {

            // Containment box
            graphics "Box" {
                float s <- world_size;
                float h <- wall_height;
                list<point> base <- [{0, 0, 0}, {s, 0, 0}, {s, s, 0}, {0, s, 0}];
                loop k from: 0 to: 3 {
                    point a <- base[k];
                    point b <- base[(k + 1) mod 4];
                    // floor edge
                    draw line([a, b]) color: rgb(64, 64, 96);
                    // top edge
                    draw line([{a.x, a.y, h}, {b.x, b.y, h}]) color: rgb(48, 48, 80);
                    // vertical edge
                    draw line([a, {a.x, a.y, h}]) color: rgb(48, 48, 80);
                }
            }

            // Particles
            species particle aspect: default;

            // Motion trails
            graphics "Trails" {
                if (show_trails) {
                    loop p over: particle {
                        if (length(p.trail) > 1) {
                            draw line(p.trail) color: p.pcolor;
                        }
                    }
                }
            }

            // HUD overlay
            overlay position: {10 #px, 10 #px} size: {260 #px, 110 #px} background: #black transparency: 0.5 border: #gray rounded: true {
                draw "Particles: " + length(particle)
                    at: {12 #px, 22 #px} color: #white font: font("Arial", 14, #bold);
                draw "Kinetic Energy: " + (total_kinetic_energy with_precision 1) + " J"
                    at: {12 #px, 45 #px} color: rgb(0, 255, 136) font: font("Arial", 14, #bold);
                draw "Avg Speed: " + (avg_speed with_precision 2) + " m/s"
                    at: {12 #px, 68 #px} color: rgb(255, 170, 0) font: font("Arial", 14, #bold);
                draw "Collisions: " + collision_count
                    at: {12 #px, 91 #px} color: rgb(255, 85, 85) font: font("Arial", 14, #bold);
            }
        }
    }
}