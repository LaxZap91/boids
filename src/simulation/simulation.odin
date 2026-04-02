package simulation

import rl "vendor:raylib"
import "assets"
import "core:mem"
import "core:fmt"

// Width of the raylib window
SCREEN_WIDTH :: 2000
// Height of the raylib window
SCREEN_HEIGHT :: 2000
// FPS target
TARGET_FPS :: 60

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	// Initialize boids
	boids := make_boids(BOID_COUNT, BOID_SPEED)
	defer delete(boids)
	predators := make_boids(PREDATOR_COUNT, PREDATOR_SPEED)
	defer delete(predators)

	// Raylib initialization
	rl.SetTraceLogLevel(rl.TraceLogLevel.WARNING)
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Boids")
	defer rl.CloseWindow()
	rl.SetTargetFPS(TARGET_FPS)

	// Loads boid image
	boid_image := rl.LoadImageFromMemory(assets.BOID_EXT, assets.BOID_PTR, assets.BOID_SIZE)
	defer rl.UnloadImage(boid_image)
	boid_texture := rl.LoadTextureFromImage(boid_image)
	defer rl.UnloadTexture(boid_texture)

	// Loads predator image
	predator_image := rl.LoadImageFromMemory(assets.BOID_EXT, assets.BOID_PTR, assets.BOID_SIZE)
	defer rl.UnloadImage(predator_image)
	predator_texture := rl.LoadTextureFromImage(predator_image)
	defer rl.UnloadTexture(predator_texture)

	// Main loop
	for !rl.WindowShouldClose() {
		// Update
		update_boids(boids, predators)
		update_predators(predators, boids)

		// Draw
		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)
		draw_boids(boid_texture, boids)
		draw_predators(predator_texture, predators)

		rl.EndDrawing()

		free_all(context.temp_allocator)
	}
}
