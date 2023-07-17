package main

import "core:mem/virtual"
import "core:fmt"

print :: fmt.println

GameMode :: enum {
	GAME_MODE_PLAY,
	GAME_MODE_MENU,
	GAME_MODE_DEBUG,
	GAME_MODE_PAUSE,
}

PlatformState :: struct {
	running    : bool,
	game_mode  : GameMode,
	arena      : virtual.Arena, //static arena
	temp_arena : virtual.Arena, //static arena
	fps        : i32,
}
