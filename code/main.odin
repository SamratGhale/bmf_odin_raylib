package main

import "core:fmt"
import "core:runtime"
import "core:mem/virtual"
import rl "vendor:raylib"

SCREEN_WIDTH  :: 1920
SCREEN_HEIGHT :: 1080

platform : PlatformState = {};

initilize_platform :: proc(){
	using virtual
	total_size : uint = runtime.Gigabyte
	err := arena_init_static(&platform.arena, total_size, total_size)
	err = arena_init_static(&platform.temp_arena, total_size, total_size)

	if err != runtime.Allocator_Error.None {
		print(err)
	}else{
		//NEAT?
		push_struct(&platform.arena, GameState)
	}
}

main :: proc(){
	initilize_platform()
	using rl
	config : ConfigFlags;
	config = {.MSAA_4X_HINT, .VSYNC_HINT, .WINDOW_HIGHDPI, .FULLSCREEN_MODE }
	SetConfigFlags(config)

	InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Test Game")
	defer CloseWindow();

	SetTargetFPS(60)

	for ! WindowShouldClose(){
		update_game();
	}
}

