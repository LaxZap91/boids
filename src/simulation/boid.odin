package simulation

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

// Scale of boid sprite
BOID_SCALE :: 0.25
// Color that boid gets rendered with
BOID_COLOR :: rl.BLUE
// Color that debug information for boid gets rendered with
BOID_DEBUG_COLOR :: rl.GREEN

// Enables drawing boid speed line
BOID_DRAW_SPEED :: false
// Enables drawing boid neighbor, predator, and wall range
BOID_DRAW_RANGE :: false
// Enables drawing boid neighbor range
BOID_DRAW_NEIGHBOR_RANGE :: false
// Enables drawing boid predator range
BOID_DRAW_PREDATOR_RANGE :: false
// Enables drawing boid wall range
BOID_DRAW_WALL_RANGE :: false
// Enables drawing the average position of all boids
BOID_DRAW_CENTER :: false
// Enables drawing boid wall
BOID_DRAW_WALL :: false

// Number of boids to simulate
BOID_COUNT :: 350
// Speed of boids
BOID_SPEED :: 35
// Range of boids neighborhood
BOID_NEIGHBOR_RANGE :: 150
// Angle of boids neighborhood (-angle, angle)
BOID_NEIGHBOR_ANGLE :: 135
// Proportion of velocity adjustment made by boids moving away from each other
BOID_SEPERATION_PROPORTION :: 30
// Proportion of velocity adjustment made by aligning nearby boids direction
BOID_ALIGNMENT_PROPORTION :: 6
// Proportion of veloicty adjustment made by moving boids togeather
BOID_COHESION_PROPORTION :: 140
// Range of a boids wall sensing
BOID_WALL_RANGE :: 200
// Amount of adjustment made to velocity if the boid is inside a wall
BOID_WALL_AVOIDANCE :: 30
// Range that boids sense predators
BOID_PREDATOR_RANGE :: 250
// Angle that boids sense predators (-angle, angle)
BOID_PREDATOR_ANGLE :: 180
// Proportion of velocity adjustment made by nearby predators
BOID_PREDATOR_FLEE_PROPORTION :: 5
// Proportion of previous velocity to be added
BOID_PREVIOUS_PROPORTION :: 500

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
