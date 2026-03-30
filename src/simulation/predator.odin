package simulation

import rl "vendor:raylib"

// Scale of predator sprite
PREDATOR_SCALE :: 0.5
// Color that predator gets rendered with
PREDATOR_COLOR :: rl.RED
// Color that debug information for predator gets rendered with
PREDATOR_DEBUG_COLOR :: rl.GREEN

// Enables drawing predator speed line
PREDATOR_DRAW_SPEED :: false
// Enables drawing predator neighbor, prey, and wall range
PREDATOR_DRAW_RANGE :: false
// Enables drawing predator neighbor range
PREDATOR_DRAW_NEIGHBOR_RANGE :: false
// Enables drawing predator prey range
PREDATOR_DRAW_BOID_RANGE :: false
// Enables drawing predator wall range
PREDATOR_DRAW_WALL_RANGE :: false
// Enables drawing predator wall
PREDATOR_DRAW_WALL :: false

// Number of predators to simulate
PREDATOR_COUNT :: 5
// Speed of predators
PREDATOR_SPEED :: BOID_SPEED - 5
// Range of predators neighborhood
PREDATOR_NEIGHBOR_RANGE :: 200
// Angle of predators neighborhood (-angle, angle)
PREDATOR_NEIGHBOR_ANGLE :: 135
// Proportion of velocity adjustment made by predators moving away from each other
PREDATOR_SEPERATION_PROPORTION :: 25
// Proportion of veloicty adjustment made by moving predators togeather
PREDATOR_COHESION_PROPORTION :: 130
// Range of a predators wall sensing
PREDATOR_WALL_RANGE :: 300
// Amount of adjustment made to velicty if the predator is inside a wall
PREDATOR_WALL_AVOIDANCE :: 15
// Range that predators sense far away boids
PREDATOR_BOID_FAR_RANGE :: BOID_PREDATOR_RANGE + 300
// Range that predators sense close boids
PREDATOR_BOID_CLOSE_RANGE :: BOID_PREDATOR_RANGE + 100
// Angle that predators sense far away boids (-angle, angle)
PREDATOR_BOID_FAR_ANGLE :: 45
// Angle that predators sense close boids (-angle, angle)
PREDATOR_BOID_CLOSE_ANGLE :: 100
// Proportion of velocity adjustment made by far away boids
PREDATOR_CHASE_FAR_PROPORTION :: 45
// Proportion of velocity adjustment made by close boids
PREDATOR_CHASE_CLOSE_PROPORTION :: 70
// Proportion of velocity adjustment made by the center of all boids
PREDATOR_CHASE_CENTER_PROPORTION :: -300
// Proportion of previous velocity to be added
PREDATOR_PREVIOUS_PROPORTION :: 350
