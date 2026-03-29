package simulation

import rl "vendor:raylib"

// Path to sprite for predator
PREDATOR_SPRITE_PATH :: "assets/boid.png"
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
PREDATOR_DRAW_BOID_RANGE :: true
// Enables drawing predator wall range
PREDATOR_DRAW_WALL_RANGE :: false
// Enables drawing predator wall
PREDATOR_DRAW_WALL :: false

// Number of predators to simulate
PREDATOR_COUNT :: 5
// Speed of predators
PREDATOR_SPEED :: 45
// Range of predators neighborhood
PREDATOR_NEIGHBOR_RANGE :: 200
// Angle of predators neighborhood (-angle, angle)
PREDATOR_NEIGHBOR_ANGLE :: 135
// Proportion of velocity adjustement made by predators moving away from each other
PREDATOR_SEPERATION_PROPORTION :: 25
// Proportion of veloicty adjustement made by moving predators togeather
PREDATOR_COHESION_PROPORTION :: 90
// Range of a predators wall sensing
PREDATOR_WALL_RANGE :: 300
// Amount of adjustement made to velicty if the predator is inside a wall
PREDATOR_WALL_AVOIDANCE :: 25
// Range that predators sense boids
PREDATOR_BOID_RANGE :: BOID_PREDATOR_RANGE + 300
// Angle that predators sense boids (-angle, angle)
PREDATOR_BOID_ANGLE :: 120
// Proportion of velocity adjustement made by nearby boids
PREDATOR_CHASE_PROPORTION :: 60
