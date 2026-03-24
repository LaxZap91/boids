package simulation

import rl "vendor:raylib"

// Raylib constants
SCREEN_WIDTH :: 2000
SCREEN_HEIGHT :: 2000
TARGET_FPS :: 60

main :: proc() {
	// Initialize boids
	boids := make_boids()
	predators := make_predators()

	// Raylib initialization
	rl.SetTraceLogLevel(rl.TraceLogLevel.WARNING)
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Boids")
	defer rl.CloseWindow()
	rl.SetTargetFPS(TARGET_FPS)

	// Loads boid image
	boid_image := rl.LoadImage(BOID_SPRITE_PATH)
	defer rl.UnloadImage(boid_image)
	boid_texture := rl.LoadTextureFromImage(boid_image)
	defer rl.UnloadTexture(boid_texture)

	// Loads predator image
	predator_image := rl.LoadImage(PREDATOR_SPRITE_PATH)
	defer rl.UnloadImage(predator_image)
	predator_texture := rl.LoadTextureFromImage(predator_image)
	defer rl.UnloadTexture(predator_texture)

	// Main loop
	for !rl.WindowShouldClose() {
		// Update
		update_boids(boids[:], predators[:])
		update_predators(predators[:], boids[:])

		// Draw
		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)

		draw_boids(boid_texture, boids[:])
		draw_predators(predator_texture, predators[:])

		rl.EndDrawing()
	}
}
