package main

import rl "vendor:raylib"
import "core:math/linalg"

LowEntity :: struct {
	pos: WorldPos,
	sim: SimEntity,
}

EntityFlags :: enum {
	entity_flag_simming	      = (1 << 1),
	entity_undo		          = (1 << 2),
	entity_flag_dead	      = (1 << 8),
	entity_flag_falling	      = (1 << 9),
	entity_flag_jumping	      = (1 << 10),
	entity_flag_on_ground	  = (1 << 11),
	entity_anim_stretch_side  = (1 << 12), //if true then width else height
}

add_flag :: #force_inline proc(val: ^u32, flag: u32) {
	val := val
	val^ |= flag
}

is_flag_set :: #force_inline proc(val: u32, flag: u32) -> b32 {
	return b32(val & flag)
}

clear_flag :: #force_inline proc(val: ^u32, flag: u32) {
	val := val
	val^ &= ~flag
}


FaceDirection :: enum {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

SimEntity :: struct{
	type      : EntityType,
	pos       : vec3,
	dP        : v3_f32,
	color     : v4, //maybe we can just use color for now
	height    : f32,
	width     : f32,
	collides  : bool,
	storage_index:  u32,
	face_direction: FaceDirection,
	flags     : u32,

//only pointer because we just wanna make one copy unless in exceptional case 
	model     : ^rl.Model,
	texture   : ^rl.Texture,  
	//add tex handle
}


EntityType::enum
{
	entity_type_null,
	entity_type_player,
	entity_type_enemy,
	entity_type_wall,
};


//do we need this?
AddEntityResult :: struct{
	entity_index : u32,
	low          : ^LowEntity,
}

add_low_entity :: proc(game_state: ^GameState, type: EntityType, pos: WorldPos)-> AddEntityResult{
	result : AddEntityResult 
	result.entity_index = game_state.low_entities_count;
	game_state.low_entities_count+=1

	low := &game_state.low_entities[result.entity_index]
	low.pos = {}
	low.pos.chunk.x = TILE_CHUNK_UNINITILIZED

	if type != .entity_type_null && result.entity_index > 0 {
		change_entity_location(&platform.arena, game_state.world, result.entity_index, low, pos)
	}

	low.sim.storage_index = result.entity_index
	low.sim.type = type

	result.low = low
	return result;
}

add_wall :: proc(game_state: ^GameState, pos: WorldPos, model: ^rl.Model)->AddEntityResult{
	chunk := get_world_chunk(game_state.world, pos.chunk)

	result := add_low_entity(game_state, .entity_type_wall, pos)
	result.low.sim.width    = 1.0
	result.low.sim.height   = 1.0
	result.low.sim.collides = true
	result.low.sim.model    = model 

	return result;
}

add_player :: proc(game_state: ^GameState, pos: WorldPos)->AddEntityResult{
	chunk := get_world_chunk(game_state.world, pos.chunk)

	result := add_low_entity(game_state, .entity_type_player, pos)
	result.low.sim.width    = 1.0
	result.low.sim.height   = 1.0
	result.low.sim.collides = true

	result.low.sim.model   = &player_model
	return result;
}


MoveSpec :: struct {
	unit_max_accel_vector: bool,
	speed:                 f32,
	drag:                  f32,
}

default_move_spec :: proc() -> MoveSpec {
	result: MoveSpec
	result.unit_max_accel_vector = false
	result.speed = 1.0
	result.drag = 0.0
	return result
}


move_entity :: proc(
	game_state : ^GameState,
	sim_region: ^SimRegion,
	entity: ^SimEntity,
	dt: f32,
	move_spec: ^MoveSpec,
	ddp: v3_f32,
) {
	using linalg
	ddp := ddp
	if move_spec.unit_max_accel_vector {
		ddp_len := length_sq(ddp)

		if ddp_len > 1.0 {
			ddp = ddp * (1.0 / sq_root(ddp_len))
		}
	}

	ddp *= move_spec.speed
	ddp += -move_spec.drag * entity.dP
	delta := (0.5 * ddp * square(dt) + entity.dP * dt)

	entity.pos += delta

	entity.dP = ddp * dt + entity.dP


}


