package main

import "core:mem/virtual"
import "core:fmt"
import "core:math/linalg"
import "core:thread"

print :: fmt.println

vec3f :: linalg.Vector3f32
vec3  :: linalg.Vector3f32
vec4  :: linalg.Vector4f32
vec3i :: [3]i32
rec3  :: linalg.Matrix3x2f32

GameMode :: enum {
	GAME_MODE_MENU,
	GAME_MODE_PLAY,
	GAME_MODE_DEBUG,
	GAME_MODE_PAUSE,
}

PlatformState :: struct {
	running    : bool,
	game_mode  : GameMode,
	arena      : virtual.Arena, //static arena
	temp_arena : virtual.Arena, //static arena
	fps        : i32,
	level_files: [dynamic]string,
}
