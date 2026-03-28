package simulation

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

// Path to sprite for boid
BOID_SPRITE_PATH :: "assets/boid.png"
// Scale of boid sprite
BOID_SCALE :: 0.25
// Color that boid gets rendered with
BOID_COLOR :: rl.BLUE
// Color that debug information for boid gets rendered with
BOID_DEBUG_COLOR :: rl.GREEN

// Enables drawing boid speed line
BOID_DRAW_SPEED :: false
// Enables drawing boid neighbor and predator range
BOID_DRAW_RANGE :: false
// Enables drawing boid wall
BOID_DRAW_WALL :: false

BOID_COUNT :: 300
BOID_NEIGHBOR_RANGE :: 150
BOID_NEIGHBOR_ANGLE :: 135
BOID_SPEED :: 30
BOID_SEPERATION_PROPORTION :: 60
BOID_ALIGNMENT_PROPORTION :: 6
BOID_COHESION_PROPORTION :: 160
BOID_WALL_AVOIDANCE :: 20
BOID_WALL_RANGE :: 200
BOID_PREDATOR_RANGE :: 250
BOID_PREDATOR_FLEE_PROPORTION :: 5

Boid :: struct {
	pos: rl.Vector2,
	vel: rl.Vector2,
}

// Creates an array of boids with random position and direction
make_boids :: proc(count: uint, speed: f32) -> []Boid {
	boids := make([]Boid, count)

	for i in 0 ..< count {
		// Generates random position
		x := rand.float32_range(0, SCREEN_WIDTH)
		y := rand.float32_range(0, SCREEN_HEIGHT)

		// Generates random angle
		angle := rand.float32_range(0, 2 * rl.PI)
		vx := math.cos(angle) * speed
		vy := math.sin(angle) * speed

		// Creates boid
		pos := rl.Vector2{x, y}
		vel := rl.Vector2{vx, vy}
		boids[i] = {pos, vel}
	}

	return boids
}
