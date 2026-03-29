package simulation

import "core:slice"
import rl "vendor:raylib"

// Updates predator positions
update_predators :: proc(predators: []Boid, boids: []Boid) {
	predators_clone := slice.clone(predators)
	for &predator, index in predators {
		neighbors := get_neighbors(
			index,
			predators,
			PREDATOR_NEIGHBOR_RANGE,
			PREDATOR_NEIGHBOR_ANGLE,
		)
		nearby_boids := get_boids(predator, boids, PREDATOR_BOID_RANGE, PREDATOR_BOID_ANGLE)
		previous_velocity := predator.vel

		// Adjusts predator velocity by rules
		apply_seperation(&predator, neighbors, PREDATOR_SEPERATION_PROPORTION)
		apply_cohesion(&predator, neighbors, PREDATOR_COHESION_PROPORTION)
		apply_cohesion(&predator, nearby_boids, PREDATOR_CHASE_PROPORTION)
		apply_avoid_walls(&predator, PREDATOR_WALL_RANGE, PREDATOR_WALL_AVOIDANCE)
		clamp_speed(&predator, PREDATOR_SPEED)

		// Prevents predators sitting still if it is in the center of all nearby boids
		if rl.Vector2Length(predator.vel) == 0 {
			predator.vel = previous_velocity
		}

		// Moves predator
		predator.pos += predator.vel
		clamp_position(&predator)
	}
}
