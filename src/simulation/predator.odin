package simulation

import "core:math"
import "core:math/rand"
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
// Enables drawing predator neighbor and prey range
PREDATOR_DRAW_RANGE :: true
// Enables drawing predator wall
PREDATOR_DRAW_WALL :: false

PREDATOR_COUNT :: 3
PREDATOR_SPEED :: 25
PREDATOR_NEIGHBOR_RANGE :: 200
PREDATOR_NEIGHBOR_ANGLE :: 135
PREDATOR_SEPERATION_PROPORTION :: 60
PREDATOR_WALL_AVOIDANCE :: 15
PREDATOR_WALL_RANGE :: 100 * 2
PREDATOR_BOID_RANGE_INCREASE :: 150
PREDATOR_BOID_RANGE :: BOID_PREDATOR_RANGE + (PREDATOR_BOID_RANGE_INCREASE * 2)
PREDATOR_BOID_ANGLE :: 120
PREDATOR_CHASE_PROPORTION :: 150
