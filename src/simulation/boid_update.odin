package simulation

import "core:slice"
import rl "vendor:raylib"

// Returns distance between two boids
get_distance :: proc(boid_1, boid_2: Boid) -> f32 {
	return rl.Vector2Distance(boid_1.pos, boid_2.pos)
}

// Returns all neighbors of a boid
get_neighbors :: proc( self: int, boids: []Boid, range, angle: f32) -> []Boid {
	neighbors := make([dynamic]Boid, 0, len(boids))
	defer delete(neighbors)

	for boid, index in boids {
		if index == self {continue}

		// Adds boid if in range
		in_range := get_distance(boid, boids[self]) < range

		// Adds boid if in angle
		dot_product := rl.Vector2DotProduct(boids[self].pos, boid.pos)
		in_angle := dot_product > (angle / 180)

		if in_range && in_angle {
			append(&neighbors, boids[index])
		}
	}
	shrink(&neighbors)

	return neighbors[:]
}

// Returns all preditors nearby a boid
boid_get_predators :: proc(boid: Boid, predators: []Boid) -> []Boid {
	nearby_predators := make([dynamic]Boid, 0, len(predators))
	defer delete(nearby_predators)

	for predator, index in predators {
		// Adds predator if in range
		if get_distance(boid, predator) < BOID_PREDATOR_RANGE {
			append(&nearby_predators, predator)
		}
	}
	shrink(&nearby_predators)

	return nearby_predators[:]
}

// Moves boid away from neighbors
apply_seperation :: proc(boid: ^Boid, neighbors: []Boid, proportion: f32) {
	if len(neighbors) == 0 {return}

	// Calculates total displacement
	displacement: rl.Vector2
	for neighbor in neighbors {
		displacement -= neighbor.pos - boid.pos
	}

	// Adjusts velocity by proportion of displacement
	boid.vel += displacement / proportion
}

// Aligns boid with neighbors
boid_apply_alignment :: proc(boid: ^Boid, neighbors: []Boid) {
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
boid_apply_cohesion :: proc(boid: ^Boid, neighbors: []Boid) {
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
boid_apply_avoid_walls :: proc(boid: ^Boid) {
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

// Moves boid away from predators
boid_flee_predator :: proc(boid: ^Boid, predators: []Boid) {
	if len(predators) == 0 {return}

	// Calculates total displacement
	displacement: rl.Vector2
	for predator in predators {
		displacement -= predator.pos - boid.pos
	}

	// Adjusts velocity by proportion of displacement
	boid.vel += displacement / BOID_PREDATOR_FLEE_PROPORTION
}

// Clamps boid speed
clamp_speed :: proc(boid: ^Boid, speed: f32) {
	boid.vel = rl.Vector2ClampValue(boid.vel, speed, speed)
}

// Clamps boid position on screen
clamp_position :: proc(boid: ^Boid) {
	min_clamp := rl.Vector2{0, 0}
	max_clamp := rl.Vector2{SCREEN_WIDTH, SCREEN_HEIGHT}
	boid.pos = rl.Vector2Clamp(boid.pos, min_clamp, max_clamp)
}

// Updates boids positions
update_boids :: proc(boids: []Boid, predators: []Boid) {
	boids_clone := slice.clone(boids)
	for &boid, index in boids {
		neighbors := get_neighbors(index, boids_clone, BOID_NEIGHBOR_RANGE, BOID_NEIGHBOR_ANGLE)
		nearby_predators := boid_get_predators(boid, predators)

		// Adjusts boid velocity by rules
		apply_seperation(&boid, neighbors, BOID_SEPERATION_PROPORTION)
		boid_apply_alignment(&boid, neighbors)
		boid_apply_cohesion(&boid, neighbors)
		boid_apply_avoid_walls(&boid)
		boid_flee_predator(&boid, nearby_predators)
		clamp_speed(&boid, BOID_SPEED)

		// Moves boid
		boid.pos += boid.vel
		// clamp_position(&boid)
	}
}
