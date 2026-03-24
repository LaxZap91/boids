package simulation

import "core:slice"
import rl "vendor:raylib"

// Gets all boids nearby a predator
predator_get_boids :: proc(predator: Boid, boids: []Boid) -> []Boid {
	nearby_boids := make([dynamic]Boid, 0, len(boids))
	defer delete(nearby_boids)

	for boid, index in boids {
		// Adds boid if in range
		if get_distance(predator, boid) < PREDATOR_BOID_RANGE {
			append(&nearby_boids, boid)
		}
	}
	shrink(&nearby_boids)

	return nearby_boids[:]
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

	// Adjusts velocity by factor
	predator.vel += velocity_adjustment
}

predator_chase_boids :: proc(predator: ^Boid, boids: []Boid) {
	if len(boids) == 0 {return}

	// Calculates average position
	average_position: rl.Vector2
	for boid in boids {
		average_position += boid.pos
	}
	average_position /= f32(len(boids))

	// Adjusts velocity by proportion of displacement
	predator.vel += (average_position - predator.pos) / PREDATOR_CHASE_PROPORTION
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
		nearby_boids := predator_get_boids(predator, boids)

		// Adjusts predator velocity by rules
		predator_apply_avoid_walls(&predator)
		predator_chase_boids(&predator, nearby_boids)
		predator_clamp_speed(&predator)

		// Moves boid
		predator.pos += predator.vel
		predator_clamp_position(&predator)
	}
}
