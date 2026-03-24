package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

SCREEN_WIDTH :: 2400
SCREEN_HEIGHT :: 1200

TARGET_FPS :: 60

BOID_COUNT :: 50

Boid :: struct {
	pos: rl.Vector2,
	vel: rl.Vector2,
}

// Creates an array of boids with random position and velocity
make_boids :: proc() -> (boids: [BOID_COUNT]Boid) {
	for i in 0 ..< BOID_COUNT {
		// Generates random position
		x := rand.float32_range(0, SCREEN_WIDTH)
		y := rand.float32_range(0, SCREEN_HEIGHT)

		// Generates random angle
		angle := rand.float32_range(0, 2 * rl.PI)
		vx := math.cos(angle)
		vy := math.sin(angle)

		// Creates boid
		pos := rl.Vector2{x, y}
		vel := rl.Vector2{vx, vy}
		boids[i] = {pos, vel}
	}

	return
}

// Draws array of boids
draw_boids :: proc(boids: []Boid) {
	// Points for base triangle to be rotated
	base_top_point := rl.Vector2{0, -15}
	base_left_point := rl.Vector2{-10, 15}
	base_right_point := rl.Vector2{10, 15}

	for boid in boids {
		angle := math.atan2(boid.vel.x, -boid.vel.y)

		// Rotates base triangle and moves to boid position
		top := rl.Vector2Rotate(base_top_point, angle) + boid.pos
		left := rl.Vector2Rotate(base_left_point, angle) + boid.pos
		right := rl.Vector2Rotate(base_right_point, angle) + boid.pos

		// Draws boid
		rl.DrawTriangle(top, left, right, rl.BLUE)
	}
}

main :: proc() {
	// Initialize boids
	boids := make_boids()

	// Raylib initialization
	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Boids")
	rl.SetTargetFPS(TARGET_FPS)

	// Main loop
	for !rl.WindowShouldClose() {
		// Draw
		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)

		draw_boids(boids[:])

		rl.EndDrawing()
	}

	rl.CloseWindow()
}
