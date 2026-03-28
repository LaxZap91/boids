package simulation

import "core:slice"
import rl "vendor:raylib"

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

// Updates predator positions
update_predators :: proc(predators: []Boid, boids: []Boid) {
	predators_clone := slice.clone(predators)
	for &predator, index in predators {
		neighbors := get_neighbors(index, predators, PREDATOR_NEIGHBOR_RANGE, PREDATOR_NEIGHBOR_ANGLE)
		nearby_boids := predator_get_boids(predator, boids)

		previous_velocity := predator.vel

		// Adjusts predator velocity by rules
		apply_seperation(&predator, neighbors, PREDATOR_SEPERATION_PROPORTION)
		predator_chase_boids(&predator, nearby_boids)
		predator_apply_avoid_walls(&predator)
		clamp_speed(&predator, PREDATOR_SPEED)

		// Prevents predators sitting still if it is in the center of all nearby boids
		if rl.Vector2Length(predator.vel) == 0 {
			predator.vel = previous_velocity
			clamp_speed(&predator, PREDATOR_SPEED)
		}

		// Moves predator
		predator.pos += predator.vel
		clamp_position(&predator)
	}
}
