package main

import "core:fmt"
import rl "vendor:raylib"

SCREEN_WIDTH :: 2400
SCREEN_HEIGHT :: 1200

TARGET_FPS :: 60

main :: proc() {
	// Raylib initialization
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Boids")
	rl.SetTargetFPS(TARGET_FPS)

	// Main loop
	for !rl.WindowShouldClose() {

		// Draw
		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)

		rl.DrawRectangle(0, 0, 500, 500, rl.RED)


		rl.EndDrawing()

	}

	rl.CloseWindow()
}
