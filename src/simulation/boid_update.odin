package simulation

import "core:slice"
import "core:math"
import rl "vendor:raylib"

// Returns distance between two boids
get_distance :: proc(boid_1, boid_2: Boid) -> f32 {
	return rl.Vector2Distance(boid_1.pos, boid_2.pos)
}

// Returns all neighbors of a boid
get_neighbors :: proc(self: int, boids: []Boid, range, angle: f32) -> []Boid {
	neighbors := make([dynamic]Boid, 0, len(boids))
	defer delete(neighbors)

	for boid, index in boids {
		if index == self {continue}

		// Adds boid if in range
		in_range := get_distance(boid, boids[self]) < range

		// Adds boid if in angle
		forward := rl.Vector2Normalize(boids[self].vel)
		other := rl.Vector2Normalize(boid.pos - boids[self].pos)
		dot_product := rl.Vector2DotProduct(forward, other)
		angle_threshold := math.cos(angle * rl.DEG2RAD)
		in_angle := dot_product > angle_threshold

		if in_range && in_angle {
			append(&neighbors, boids[index])
		}
	}
	shrink(&neighbors)

	return neighbors[:]
}

// Returns all boids nearby a boid
get_boids :: proc(self: Boid, boids: []Boid, range, angle: f32) -> []Boid {
	nearby_boids := make([dynamic]Boid, 0, len(boids))
	defer delete(nearby_boids)

	for boid, index in boids {
		// Adds boid if in range
		in_range := get_distance(self, boid) < range

		// Adds boid if in angle
		forward := rl.Vector2Normalize(self.vel)
		other := rl.Vector2Normalize(boid.pos - self.pos)
		dot_product := rl.Vector2DotProduct(forward, other)
		angle_threshold := math.cos(angle * rl.DEG2RAD)
		in_angle := dot_product > angle_threshold

		if in_range && in_angle {
			append(&nearby_boids, boid)
		}
	}
	shrink(&nearby_boids)

	return nearby_boids[:]
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
apply_alignment :: proc(boid: ^Boid, neighbors: []Boid, proportion: f32) {
	if len(neighbors) == 0 {return}

	// Calculates average velocity
	average_velocity: rl.Vector2
	for neighbor in neighbors {
		average_velocity += neighbor.vel
	}
	average_velocity /= f32(len(neighbors))

	// Adjusts velocity by proportion of average velocity
	boid.vel += average_velocity / proportion
}

// Moves boid closer to neighbor
apply_cohesion :: proc(boid: ^Boid, neighbors: []Boid, proportion: f32) {
	if len(neighbors) == 0 {return}

	// Calculates average position
	average_position: rl.Vector2
	for neighbor in neighbors {
		average_position += neighbor.pos
	}
	average_position /= f32(len(neighbors))

	// Adjusts velocity by proportion of displacement
	boid.vel += (boid.pos - average_position) / proportion
}

// Moves boid away from walls
apply_avoid_walls :: proc(boid: ^Boid, range, avoidance: f32) {
	velocity_adjustment: rl.Vector2
	// Moves boid if touching horizontal wall
	if boid.pos.x < range {
		velocity_adjustment.x = avoidance
	} else if boid.pos.x > (SCREEN_WIDTH - range) {
		velocity_adjustment.x = -avoidance
	}

	// Moves boid if touching vertical wall
	if boid.pos.y < range {
		velocity_adjustment.y = avoidance
	} else if boid.pos.y > (SCREEN_HEIGHT - range) {
		velocity_adjustment.y = -avoidance
	}

	// Adjusts velocity by factor
	boid.vel += velocity_adjustment
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
		nearby_predators := get_boids(boid, predators, BOID_PREDATOR_RANGE, BOID_PREDATOR_ANGLE)
		previous_velocity := boid.vel

		// Adjusts boid velocity by rules
		apply_seperation(&boid, neighbors, BOID_SEPERATION_PROPORTION)
		apply_seperation(&boid, nearby_predators, BOID_PREDATOR_FLEE_PROPORTION)
		apply_alignment(&boid, neighbors, BOID_ALIGNMENT_PROPORTION)
		apply_cohesion(&boid, neighbors, BOID_COHESION_PROPORTION)
		apply_avoid_walls(&boid, BOID_WALL_RANGE, BOID_WALL_AVOIDANCE)
		clamp_speed(&boid, BOID_SPEED)

		// Prevents boids sitting still if it is in the center of all nearby boids
		if rl.Vector2Length(boid.vel) == 0 {
			boid.vel = previous_velocity
		}

		// Moves boid
		boid.pos += boid.vel
		// clamp_position(&boid)
	}
}
