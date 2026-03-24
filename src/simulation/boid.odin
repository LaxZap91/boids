package simulation

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

// Boid render constants
BOID_SPRITE_PATH :: "assets/boid.png"
BOID_COLOR :: rl.BLUE
BOID_DEBUG_COLOR :: rl.GREEN
BOID_SCALE :: 0.25

// Boid debug drawing
BOID_DRAW_SPEED :: false
BOID_DRAW_RANGE :: false
BOID_DRAW_WALL :: false

// Boid simulation constants
BOID_COUNT :: 250
BOID_NEIGHBOR_RANGE :: 150
BOID_SPEED :: 30
BOID_SEPERATION_PROPORTION :: 60
BOID_ALIGNMENT_PROPORTION :: 6
BOID_COHESION_PROPORTION :: 160
BOID_WALL_AVOIDANCE :: 10
BOID_WALL_RANGE :: 200
BOID_PREDATOR_RANGE :: 250
BOID_PREDATOR_FLEE_PROPORTION :: 5

Boid :: struct {
	pos: rl.Vector2,
	vel: rl.Vector2,
}

// Creates an array of boids with random position and velocity
make_boids :: proc() -> (boids: [BOID_COUNT]Boid) {
	for i in 0 ..< BOID_COUNT {
		// Generates random position
		x := rand.float32_range(0, SCREEN_WIDTH)
		y := rand.float32_range(0, SCREEN_HEIGHT)

		// Generates random angle
		angle := rand.float32_range(0, 2 * rl.PI)
		vx := math.cos(angle) * BOID_SPEED
		vy := math.sin(angle) * BOID_SPEED

		// Creates boid
		pos := rl.Vector2{x, y}
		vel := rl.Vector2{vx, vy}
		boids[i] = {pos, vel}
	}

	return
}
