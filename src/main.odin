package main

import "core:math"
import "core:math/rand"
import "core:slice"
import rl "vendor:raylib"

// Raylib constants
SCREEN_WIDTH :: 2000
SCREEN_HEIGHT :: 2000
TARGET_FPS :: 60

// Boid render constants
SPRITE_PATH :: "../assets/boid.png"
BOID_COLOR :: rl.BLUE
BOID_DEBUG_COLOR :: rl.GREEN
BOID_SCALE :: 0.25

// Boid debug drawing
BOID_DRAW_SPEED :: false
BOID_DRAW_RANGE :: false

// Boid simulation constants
BOID_COUNT :: 300
BOID_NEIGHBOR_RANGE :: 100
BOID_SPEED :: 40
BOID_SEPERATION_PROPORTION :: 40
BOID_ALIGNMENT_PROPORTION :: 4
BOID_COHESION_PROPORTION :: 170
BOID_WALL_AVOIDANCE :: 15
BOID_WALL_RANGE :: BOID_NEIGHBOR_RANGE * 4

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
draw_boids :: proc(texture: rl.Texture2D, boids: []Boid) {
	for boid in boids {
		angle := math.atan2(boid.vel.x, -boid.vel.y)

		// Transforms sprite position
		texture_size := rl.Vector2{f32(texture.width / (2 / BOID_SCALE)), f32(texture.height / (2 / BOID_SCALE))}
		texture_pos := rl.Vector2Rotate(texture_size, angle)

		// Draws boid
		rl.DrawTextureEx(texture, boid.pos - texture_pos, angle * rl.RAD2DEG, BOID_SCALE, BOID_COLOR)
		// Draw velocity
		when BOID_DRAW_SPEED {
			// Gets top of sprite
			top := rl.Vector2Rotate(rl.Vector2{0, -texture_size.y}, angle) + boid.pos
			rl.DrawLineEx(top, top + boid.vel, 4, BOID_DEBUG_COLOR)
		}
		// Draws range
		when BOID_DRAW_RANGE {
			rl.DrawCircleLinesV(boid.pos, BOID_NEIGHBOR_RANGE, BOID_DEBUG_COLOR)
		}
	}
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
		if get_distance(boid, boids[self]) < BOID_NEIGHBOR_RANGE {
			append(&neighbors, boids[index])
		}
	}
	shrink(&neighbors)

	return neighbors[:]
}

// Moves boid away from neighbors
seperation :: proc(boid: ^Boid, neighbors: []Boid) {
	if len(neighbors) == 0 {return}

	// Calculates total displacement
	displacement: rl.Vector2
	for neighbor in neighbors {
		displacement -= neighbor.pos - boid.pos
	}

	// Adjusts velocity by proportion of displacement
	boid.vel += displacement / BOID_SEPERATION_PROPORTION
}

// Aligns boid with neighbors
alignment :: proc(boid: ^Boid, neighbors: []Boid) {
	if len(neighbors) == 0 {return}

	// Calculates average velocity
	average_velocity: rl.Vector2
	for neighbor in neighbors {
		average_velocity += neighbor.vel
	}
	average_velocity /= f32(len(neighbors))

	// Adjusts velocity by proportion of average velocity
	boid.vel += average_velocity / BOID_ALIGNMENT_PROPORTION
}

// Moves boid closer to neighbor
cohesion :: proc(boid: ^Boid, neighbors: []Boid) {
	if len(neighbors) == 0 {return}

	// Calculates average position
	average_position: rl.Vector2
	for neighbor in neighbors {
		average_position += neighbor.pos
	}
	average_position /= f32(len(neighbors))

	// Adjusts velocity by proportion of displacement
	boid.vel += (boid.pos - average_position) / BOID_COHESION_PROPORTION
}

// Moves boid away from walls
avoid_walls :: proc(boid: ^Boid) {
	velocity_adjustment: rl.Vector2
	// Moves boid if touching horizontal wall
	if boid.pos.x < BOID_WALL_RANGE {
		velocity_adjustment.x = BOID_WALL_AVOIDANCE
	} else if boid.pos.x > (SCREEN_WIDTH - BOID_WALL_RANGE) {
		velocity_adjustment.x = -BOID_WALL_AVOIDANCE
	}

	// Moves boid if touching vertical wall
	if boid.pos.y < BOID_WALL_RANGE {
		velocity_adjustment.y = BOID_WALL_AVOIDANCE
	} else if boid.pos.y > (SCREEN_HEIGHT - BOID_WALL_RANGE) {
		velocity_adjustment.y = -BOID_WALL_AVOIDANCE
	}

	// Adjusts velocity by factor
	boid.vel += velocity_adjustment
}

// Clamps boid position on screen
clamp_position :: proc(boid: ^Boid) {
	min_clamp := rl.Vector2{0, 0}
	max_clamp := rl.Vector2{SCREEN_WIDTH, SCREEN_HEIGHT}
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
	rl.SetTraceLogLevel(rl.TraceLogLevel.WARNING)
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Boids")
	defer rl.CloseWindow()
	rl.SetTargetFPS(TARGET_FPS)

	// Loads boid image
	boid_image := rl.LoadImage(SPRITE_PATH)
	defer rl.UnloadImage(boid_image)
	boid_texture := rl.LoadTextureFromImage(boid_image)
	defer rl.UnloadTexture(boid_texture)

	// Main loop
	for !rl.WindowShouldClose() {
		// Update
		update_boids(boids[:])

		// Draw
		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)

		draw_boids(boid_texture, boids[:])

		rl.EndDrawing()
	}
}
