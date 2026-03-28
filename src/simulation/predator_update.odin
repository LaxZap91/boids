package simulation

import "core:slice"
import rl "vendor:raylib"

// Returns all neighbors of a predator
predator_get_neighbors :: proc(predators: []Boid, self: int) -> []Boid {
	neighbors := make([dynamic]Boid, 0, len(predators))
	defer delete(neighbors)

	for predator, index in predators {
		if index == self {continue}

		// Adds predator if in range
		in_range := get_distance(predator, predators[self]) < PREDATOR_NEIGHBOR_RANGE

		// Adds predator if in angle
		dot_product := rl.Vector2DotProduct(predators[self].pos, predator.pos)
		in_angle := dot_product > (PREDATOR_NEIGHBOR_ANGLE / 180)

		if in_range && in_angle {
			append(&neighbors, predators[index])
		}
	}
	shrink(&neighbors)

	return neighbors[:]
}

// Gets all boids nearby a predator
predator_get_boids :: proc(predator: Boid, boids: []Boid) -> []Boid {
	nearby_boids := make([dynamic]Boid, 0, len(boids))
	defer delete(nearby_boids)

	for boid, index in boids {
		// Adds boid if in range
		in_range := get_distance(predator, boid) < PREDATOR_BOID_RANGE

		// Adds boid if in angle
		dot_product := rl.Vector2DotProduct(predator.pos, boid.pos)
		in_angle := dot_product > (PREDATOR_BOID_ANGLE / 180)

		if in_range && in_angle {
			append(&nearby_boids, boid)
		}
	}
	shrink(&nearby_boids)

	return nearby_boids[:]
}

// Moves predator away from neighbors
predator_apply_seperation :: proc(predator: ^Boid, neighbors: []Boid) {
	if len(neighbors) == 0 {return}

	// Calculates total displacement
	displacement: rl.Vector2
	for neighbor in neighbors {
		displacement -= neighbor.pos - predator.pos
	}

	// Adjusts velocity by proportion of displacement
	predator.vel += displacement / PREDATOR_SEPERATION_PROPORTION
}

// Moves predator towards boids
predator_chase_boids :: proc(predator: ^Boid, boids: []Boid) {
	if len(boids) == 0 {return}

	// Calculates average position
	average_position: rl.Vector2
	for boid in boids {
		average_position += boid.pos
	}
	average_position /= f32(len(boids))

	predator.vel -= (predator.pos - average_position) / PREDATOR_CHASE_PROPORTION
}

// Moves predator away from walls
predator_apply_avoid_walls :: proc(predator: ^Boid) {
	velocity_adjustment: rl.Vector2

	// Moves boid if touching horizontal wall
	if predator.pos.x < PREDATOR_WALL_RANGE {
		velocity_adjustment.x = PREDATOR_WALL_AVOIDANCE
	} else if predator.pos.x > (SCREEN_WIDTH - PREDATOR_WALL_RANGE) {
		velocity_adjustment.x = -PREDATOR_WALL_AVOIDANCE
	}

	// Moves predator if touching vertical wall
	if predator.pos.y < PREDATOR_WALL_RANGE {
		velocity_adjustment.y = PREDATOR_WALL_AVOIDANCE
	} else if predator.pos.y > (SCREEN_HEIGHT - PREDATOR_WALL_RANGE) {
		velocity_adjustment.y = -PREDATOR_WALL_AVOIDANCE
	}

	predator.vel += velocity_adjustment
}

// Clamps predator speed
predator_clamp_speed :: proc(predator: ^Boid) {
	predator.vel = rl.Vector2ClampValue(predator.vel, PREDATOR_SPEED, PREDATOR_SPEED)
}

// Clamps predator position on screen
predator_clamp_position :: proc(predator: ^Boid) {
	min_clamp := rl.Vector2{0, 0}
	max_clamp := rl.Vector2{SCREEN_WIDTH, SCREEN_HEIGHT}
	predator.pos = rl.Vector2Clamp(predator.pos, min_clamp, max_clamp)
}

// Updates predator positions
update_predators :: proc(predators: []Boid, boids: []Boid) {
	predators_clone := slice.clone(predators)
	for &predator, index in predators {
		neighbors := predator_get_neighbors(predators, index)
		nearby_boids := predator_get_boids(predator, boids)

		// Adjusts predator velocity by rules
		predator_apply_seperation(&predator, neighbors)
		predator_chase_boids(&predator, nearby_boids)
		predator_apply_avoid_walls(&predator)
		predator_clamp_speed(&predator)

		// Moves predator
		predator.pos += predator.vel
		predator_clamp_position(&predator)
	}
}
