package simulation

import "core:math"
import rl "vendor:raylib"

// Draws array of boids
draw_boids :: proc(texture: rl.Texture2D, boids: []Boid) {
	for boid in boids {
		angle := math.atan2(boid.vel.x, -boid.vel.y)

		// Transforms sprite position
		texture_size := rl.Vector2 {
			(f32(texture.width) / 2) * BOID_SCALE,
			(f32(texture.height) / 2) * BOID_SCALE,
		}
		texture_pos := rl.Vector2Rotate(texture_size, angle)

		// Draws boid
		rl.DrawTextureEx(
			texture,
			boid.pos - texture_pos,
			angle * rl.RAD2DEG,
			BOID_SCALE,
			BOID_COLOR,
		)
		// Draw speed
		when BOID_DRAW_SPEED {
			// Gets top of sprite
			top := rl.Vector2Rotate(rl.Vector2{0, -texture_size.y}, angle) + boid.pos
			rl.DrawLineEx(top, top + boid.vel, 4, BOID_DEBUG_COLOR)
		}
		// Draws range
		when BOID_DRAW_RANGE {
			angle_offset := angle * rl.RAD2DEG - 90
			rl.DrawCircleSectorLines(
				boid.pos,
				BOID_NEIGHBOR_RANGE,
				-BOID_NEIGHBOR_ANGLE + angle_offset,
				BOID_NEIGHBOR_ANGLE + angle_offset,
				1,
				BOID_DEBUG_COLOR,
			)
			rl.DrawCircleLinesV(boid.pos, BOID_PREDATOR_RANGE, BOID_DEBUG_COLOR)
		}
	}

	when BOID_DRAW_WALL {
		wall_rect := rl.Rectangle {
			BOID_WALL_RANGE,
			BOID_WALL_RANGE,
			SCREEN_WIDTH - (2 * BOID_WALL_RANGE),
			SCREEN_HEIGHT - (2 * BOID_WALL_RANGE),
		}
		rl.DrawRectangleLinesEx(wall_rect, 4, BOID_DEBUG_COLOR)
	}
}
