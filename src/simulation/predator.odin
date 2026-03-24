package simulation

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

// Predator render constants
PREDATOR_SPRITE_PATH :: "assets/boid.png"
PREDATOR_COLOR :: rl.RED
PREDATOR_DEBUG_COLOR :: rl.GREEN
PREDATOR_SCALE :: 0.5

// Predator debug drawing
PREDATOR_DRAW_SPEED :: false
PREDATOR_DRAW_RANGE :: false
PREDATOR_DRAW_WALL :: false

// Predator simulation constants
PREDATOR_COUNT :: 3
PREDATOR_SPEED :: 30
PREDATOR_WALL_AVOIDANCE :: 10
PREDATOR_WALL_RANGE :: 100 * 2
PREDATOR_BOID_RANGE :: 800
PREDATOR_CHASE_PROPORTION :: 50

// Creates an array of predators with random position and velocity
make_predators :: proc() -> (predators: [PREDATOR_COUNT]Boid) {
	for i in 0 ..< PREDATOR_COUNT {
		// Generates random position
		x := rand.float32_range(0, SCREEN_WIDTH)
		y := rand.float32_range(0, SCREEN_HEIGHT)

		// Generates random angle
		angle := rand.float32_range(0, 2 * rl.PI)
		vx := math.cos(angle) * PREDATOR_SPEED
		vy := math.sin(angle) * PREDATOR_SPEED

		// Creates predator
		pos := rl.Vector2{x, y}
		vel := rl.Vector2{vx, vy}
		predators[i] = {pos, vel}
	}

	return
}
