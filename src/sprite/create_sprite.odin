package sprite

import rl "vendor:raylib"

SPRITE_PATH :: "../assets/boid.png"
SPRITE_WIDTH :: 60
SPRITE_HEIGHT :: 160
SPRITE_COLOR :: rl.WHITE

TOP := rl.Vector2{(SPRITE_WIDTH/2), SPRITE_HEIGHT}
LEFT := rl.Vector2{SPRITE_WIDTH, 0}
RIGHT := rl.Vector2{0, 0}
CENTER := rl.Vector2{(SPRITE_WIDTH/2), (SPRITE_HEIGHT/3)}

main :: proc() {
	rl.SetConfigFlags({.WINDOW_HIDDEN})
	rl.InitWindow(1, 1, "")
	rl.SetTraceLogLevel(rl.TraceLogLevel.WARNING)

	texture := rl.LoadRenderTexture(SPRITE_WIDTH, SPRITE_HEIGHT)

	rl.BeginTextureMode(texture)
	rl.ClearBackground(rl.BLANK)

	rl.DrawTriangle(TOP, LEFT, CENTER, SPRITE_COLOR)
	rl.DrawTriangle(TOP, CENTER, RIGHT, SPRITE_COLOR)

	rl.EndTextureMode()

	texture2d := texture.texture
	image := rl.LoadImageFromTexture(texture2d)
	rl.ExportImage(image, SPRITE_PATH)

	rl.CloseWindow()
}
