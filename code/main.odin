package main

import "core:fmt"
import "core:runtime"
import "core:mem/virtual"
import rl "vendor:raylib"
import "core:os"
import "core:encoding/json"

screen_width  : i32= 960
screen_height : i32= 540

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

parse_config :: proc(){
	using json
	data, success := os.read_entire_file("../code/config.json")
	if(success){
		parsed, err := json.parse(data, .MJSON, true)

		if err == .None {
			root := parsed.(json.Object)

			screen_height = i32(root["screen_height"].(i64))
			screen_width  = i32(root["screen_width"].(i64))
			ambience := root["ambience"].(Array)
			vec_ambience : vec4 = {f32(ambience[0].(f64)), f32(ambience[1].(f64)), f32(ambience[2].(f64)), f32(ambience[3].(f64))}

			level_files := root["level_files"].(Array)

			for i in 0..< len(level_files){
				append(&platform.level_files ,level_files[i].(string))
			}

		}else{
			print(err)
		}
	}else{
		print("Failed to read file")
	}
}

main :: proc(){
	initilize_platform()
	using rl
	config : ConfigFlags;
	config = {.MSAA_4X_HINT, .VSYNC_HINT, .WINDOW_HIGHDPI}
	SetConfigFlags(config)
	parse_config();

	InitWindow(i32(screen_width), i32(screen_height), "Test Game")
	defer CloseWindow();

	SetTargetFPS(60)


	for ! WindowShouldClose(){
		update_game();
	}
}

