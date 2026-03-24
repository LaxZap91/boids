package simulation

import "core:math"
import rl "vendor:raylib"

// Draws array of predators
draw_predators :: proc(texture: rl.Texture2D, predators: []Boid) {
	for predator in predators {
		angle := math.atan2(predator.vel.x, -predator.vel.y)

		// Transforms sprite position
		texture_size := rl.Vector2 {
			f32(texture.width) / (2 / PREDATOR_SCALE),
			f32(texture.height) / (2 / PREDATOR_SCALE),
		}
		texture_pos := rl.Vector2Rotate(texture_size, angle)

		// Draws predator
		rl.DrawTextureEx(
			texture,
			predator.pos - texture_pos,
			angle * rl.RAD2DEG,
			PREDATOR_SCALE,
			PREDATOR_COLOR,
		)
		// Draw speed
		when PREDATOR_DRAW_SPEED {
			// Gets top of sprite
			top := rl.Vector2Rotate(rl.Vector2{0, -texture_size.y}, angle) + predator.pos
			rl.DrawLineEx(top, top + predator.vel, 4, PREDATOR_DEBUG_COLOR)
		}
		// Draws range
		when PREDATOR_DRAW_RANGE {
			rl.DrawCircleLinesV(predator.pos, PREDATOR_BOID_RANGE, PREDATOR_DEBUG_COLOR)
		}
	}

	when PREDATOR_DRAW_WALL {
		wall_rect := rl.Rectangle{
			PREDATOR_WALL_RANGE,
			PREDATOR_WALL_RANGE,
			SCREEN_WIDTH - (2 * PREDATOR_WALL_RANGE),
			SCREEN_HEIGHT - (2 * PREDATOR_WALL_RANGE),
		}
		rl.DrawRectangleLinesEx(wall_rect, 4, PREDATOR_DEBUG_COLOR)
	}
}
