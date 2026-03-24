package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import "core:slice"
import rl "vendor:raylib"

SCREEN_WIDTH :: 2400
SCREEN_HEIGHT :: 1200

TARGET_FPS :: 60

BOID_COUNT :: 200
BOID_RANGE :: 100
BOID_SPEED :: 25
BOID_WALL_AVOIDANCE :: 20

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

// Draws array of boids
draw_boids :: proc(boids: []Boid) {
	// Points for base triangle to be rotated
	base_top_point := rl.Vector2{0, -15}
	base_left_point := rl.Vector2{-10, 15}
	base_right_point := rl.Vector2{10, 15}

	for boid in boids {
		angle := math.atan2(boid.vel.x, -boid.vel.y)

		// Rotates base triangle and moves to boid position
		top := rl.Vector2Rotate(base_top_point, angle) + boid.pos
		left := rl.Vector2Rotate(base_left_point, angle) + boid.pos
		right := rl.Vector2Rotate(base_right_point, angle) + boid.pos

		// Draws boid
		rl.DrawTriangle(top, left, right, rl.BLUE)
		// Draw velocity
		// rl.DrawLineEx(boid.pos, top + boid.vel, 2, rl.BLUE)
		// Draws range
		// rl.DrawCircleLinesV(boid.pos, BOID_RANGE, rl.RED)
	}

	// Draws avoidance box
	// rl.DrawRectangleLines(
	// 	BOID_RANGE, BOID_RANGE,
	// 	SCREEN_WIDTH - (2 * BOID_RANGE), SCREEN_HEIGHT - (2 * BOID_RANGE),
	// 	rl.RED,
	// )
}

// Returns distance between two boids
get_distance :: proc(boid_1, boid_2: Boid) -> f32 {
	return rl.Vector2Distance(boid_1.pos, boid_2.pos)
}

// Returns all neighbors of a boid
get_neighbors :: proc(boids: []Boid, self: int) -> []Boid {
	neighbors := make([dynamic]Boid, 0, len(boids))
	defer delete(neighbors)

	for boid, index in boids {
		if index == self {continue}

		// Adds boid if in range
		if get_distance(boid, boids[self]) < BOID_RANGE {
			append(&neighbors, boids[index])
		}
	}
	shrink(&neighbors)

	return neighbors[:]
}

// Seperates boids
seperation :: proc(boid: ^Boid, neighbors: []Boid) {
	if len(neighbors) == 0 {return}

	// Calculates total displacement
	displacement: rl.Vector2
	for neighbor in neighbors {
		displacement -= neighbor.pos - boid.pos
	}

	// Adjusts velocity by proportion of displacement
	boid.vel += displacement / 25
}

// Aligns direction of nearby boids
alignment :: proc(boid: ^Boid, neighbors: []Boid) {
	if len(neighbors) == 0 {return}

	// Calculates average velocity
	average_velocity: rl.Vector2
	for neighbor in neighbors {
		average_velocity += neighbor.vel
	}
	average_velocity /= f32(len(neighbors))

	// Adjusts velocity by proportion of average velocity
	boid.vel += average_velocity / 4
}

// Groups boids together
cohesion :: proc(boid: ^Boid, neighbors: []Boid) {
	if len(neighbors) == 0 {return}

	// Calculates average position
	average_position: rl.Vector2
	for neighbor in neighbors {
		average_position += neighbor.pos
	}
	average_position /= f32(len(neighbors))

	// Adjusts velocity by proportion of displacement
	boid.vel += (boid.pos - average_position) / 100
}

// Moves boid away from walls
avoid_walls :: proc(boid: ^Boid) {
	velocity_adjustment: rl.Vector2
	// Moves boid if touching horizontal wall
	if boid.pos.x < BOID_RANGE {
		velocity_adjustment.x = BOID_WALL_AVOIDANCE
	}
	else if boid.pos.x > (SCREEN_WIDTH - BOID_RANGE) {
		velocity_adjustment.x = -BOID_WALL_AVOIDANCE
	}

	// Moves boid if touching vertical wall
	if boid.pos.y < BOID_RANGE {
		velocity_adjustment.y = BOID_WALL_AVOIDANCE
	}
	else if boid.pos.y > (SCREEN_HEIGHT - BOID_RANGE) {
		velocity_adjustment.y = -BOID_WALL_AVOIDANCE
	}

	// Adjusts velocity by factor
	boid.vel += velocity_adjustment
}

// Clamps boid position on screen
clamp_position :: proc(boid: ^Boid) {
	min_clamp := rl.Vector2{15, 15}
	max_clamp := rl.Vector2{SCREEN_WIDTH - 15, SCREEN_HEIGHT - 15}
	boid.pos = rl.Vector2Clamp(boid.pos, min_clamp, max_clamp)
}

// Clamps boid speed
clamp_speed :: proc(boid: ^Boid) {
	boid.vel = rl.Vector2ClampValue(boid.vel, BOID_SPEED, BOID_SPEED)
}

// Updates boids positions
update_boids :: proc(boids: []Boid) {
	boids_clone := slice.clone(boids)
	for &boid, index in boids {
		neighbors := get_neighbors(boids_clone, index)

		// Adjusts boid velocity by rules
		seperation(&boid, neighbors)
		alignment(&boid, neighbors)
		cohesion(&boid, neighbors)
		avoid_walls(&boid)
		clamp_speed(&boid)

		// Moves boid
		boid.pos += boid.vel
		clamp_position(&boid)
	}
}

main :: proc() {
	// Initialize boids
	boids := make_boids()

	// Raylib initialization
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Boids")
	rl.SetTargetFPS(TARGET_FPS)

	// Main loop
	for !rl.WindowShouldClose() {
		// Update
		update_boids(boids[:])

		// Draw
		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)

		draw_boids(boids[:])

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
