package main

import "core:fmt"
import "core:runtime"
import "core:mem/virtual"
import rl "vendor:raylib"

SCREEN_WIDTH  :: 1920
SCREEN_HEIGHT :: 1000

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

	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Test Game")
	defer rl.CloseWindow();

	rl.SetTargetFPS(60)

	for ! rl.WindowShouldClose(){
		update_game();
	}
}

