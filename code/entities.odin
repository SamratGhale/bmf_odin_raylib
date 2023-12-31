package main

import rl "vendor:raylib"
import "core:fmt"
import "core:math/linalg"

FLT_MAX :: 340282346638528859811704183484516925440.0


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
	LEFT,
	DOWN,
	RIGHT,
}
total_light_count : u32= 0

SimEntity :: struct{
	type      : EntityType,
	pos       : vec3,
	dP        : vec3,
	color     : vec4, //maybe we can just use color for now
	height    : f32,
	width     : f32,
	collides  : bool,
	storage_index:  u32,
	face_direction: FaceDirection,
	flags     : u32,

//only pointer because we just wanna make one copy unless in exceptional case 
	model     : AssetTypeModel,
	texture   : ^rl.Texture,  
	light_index: u32,
<<<<<<< HEAD

	bound_box : rl.BoundingBox,
	coll_box     : rl.RayCollision,
=======
>>>>>>> c60edaae515706ebfb94df981545583986655d4b

	//add tex handle
}


EntityType::enum
{
	entity_type_null,
	entity_type_player,
	entity_type_enemy,
	entity_type_wall,
	entity_type_house,
	entity_type_grimchild,
	entity_type_stone,
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

add_wall :: proc(game_state: ^GameState, pos: WorldPos, model: AssetTypeModel )->AddEntityResult{
	chunk := get_world_chunk(game_state.world, pos.chunk)

	result := add_low_entity(game_state, .entity_type_wall, pos)
	result.low.sim.width    = 1.0
	result.low.sim.height   = 1.0
	result.low.sim.collides = true
	result.low.sim.model    = model 


	models := game_state.asset.models

	result.low.sim.bound_box = rl.GetModelBoundingBox(models[result.low.sim.model])
	//result.low.sim.coll_box  = rl.GetRayCollisionBox(models[result.low.sim.model])

	return result;
}

<<<<<<< HEAD
add_stone:: proc(game_state: ^GameState, pos: WorldPos, model: AssetTypeModel)->AddEntityResult{
=======
add_stone:: proc(game_state: ^GameState, pos: WorldPos, model: ^rl.Model)->AddEntityResult{
>>>>>>> c60edaae515706ebfb94df981545583986655d4b
	chunk := get_world_chunk(game_state.world, pos.chunk)

	result := add_low_entity(game_state, .entity_type_stone, pos)
	result.low.sim.width    = 10.0
	result.low.sim.height   = 10.0
	result.low.sim.collides = true
	result.low.sim.model    = model 
<<<<<<< HEAD

	models := game_state.asset.models
	result.low.sim.bound_box = rl.GetModelBoundingBox(models[result.low.sim.model])
=======
>>>>>>> c60edaae515706ebfb94df981545583986655d4b
	return result;
}


<<<<<<< HEAD
add_house:: proc(game_state: ^GameState, pos: WorldPos, model: AssetTypeModel )->AddEntityResult{
=======
add_house:: proc(game_state: ^GameState, pos: WorldPos, model: ^rl.Model)->AddEntityResult{
>>>>>>> c60edaae515706ebfb94df981545583986655d4b
	chunk := get_world_chunk(game_state.world, pos.chunk)

	result := add_low_entity(game_state, .entity_type_house, pos)
	result.low.sim.width    = 1.0
	result.low.sim.height   = 1.0
	result.low.sim.collides = false
	result.low.sim.model    = model 

	return result;
}

add_player :: proc(game_state: ^GameState, pos: WorldPos)->AddEntityResult{
	chunk := get_world_chunk(game_state.world, pos.chunk)

	result := add_low_entity(game_state, .entity_type_player, pos)
	result.low.sim.width    = 1.0
	result.low.sim.height   = 1.0
	result.low.sim.collides = true

<<<<<<< HEAD
	asset := game_state.asset

	result.low.sim.model       = .PLAYER
	result.low.sim.light_index = total_light_count
	asset.lights[total_light_count]  = create_light(.POINT, result.low.sim.pos, {}, rl.WHITE, asset.shader)
	total_light_count += 1
	models := game_state.asset.models
	result.low.sim.bound_box = rl.GetModelBoundingBox(models[result.low.sim.model])
=======
	result.low.sim.model       = &player_model
	result.low.sim.light_index = total_light_count
	lights[total_light_count]  = create_light(.POINT, result.low.sim.pos, {}, rl.WHITE, shader)
	total_light_count += 1
>>>>>>> c60edaae515706ebfb94df981545583986655d4b
	return result;
}

add_grimchild :: proc(game_state: ^GameState, pos: WorldPos)->AddEntityResult{
	chunk := get_world_chunk(game_state.world, pos.chunk)

	result := add_low_entity(game_state, .entity_type_grimchild, pos)
	result.low.sim.width    = 1.0
	result.low.sim.height   = 1.0
<<<<<<< HEAD
	result.low.sim.collides = false

	asset := game_state.asset
	result.low.sim.model   = .GRIMCHILD
	result.low.sim.light_index = total_light_count
	asset.lights[total_light_count] = create_light(.POINT, result.low.sim.pos, {}, rl.BLUE, asset.shader)
	//total_light_count += 1
	models := game_state.asset.models
	result.low.sim.bound_box = rl.GetModelBoundingBox(models[result.low.sim.model])
=======
	result.low.sim.collides = true
	result.low.sim.model   = &grimchild_model
	result.low.sim.light_index = total_light_count
	lights[total_light_count] = create_light(.POINT, result.low.sim.pos, {}, rl.BLUE, shader)
	//total_light_count += 1
>>>>>>> c60edaae515706ebfb94df981545583986655d4b
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
	old_ddp: vec3,
) {
	ddp := old_ddp

	using linalg
	if move_spec.unit_max_accel_vector {
		ddp_len := inner_product(old_ddp, old_ddp)

		if ddp_len > 1.0 {
			ddp = ddp * (1.0 / sqrt(ddp_len))
		}
	}


	switch(entity.face_direction){
	case .UP:{
	}
	case .DOWN:{
		ddp = -ddp
	}
	case .RIGHT, .LEFT:{
		ddp = linalg.vector3f32_swizzle3(ddp, .z, .y, .x)
		if(entity.face_direction == .RIGHT){
			ddp.x = -ddp.x
		}else{
			ddp.z *= -1
		}
	}
	}

	ddp *= move_spec.speed
	ddp += -move_spec.drag * entity.dP
	delta := (0.5 * ddp * dt * dt + entity.dP * dt)

	ray :rl.Ray={} 
	ray.position  = entity.pos
	ray.direction = delta 

	hit := false

	nearest_collision : rl.RayCollision;
<<<<<<< HEAD
	models := &game_state.asset.models
=======
>>>>>>> c60edaae515706ebfb94df981545583986655d4b
	for i in 0..<sim_region.entity_count{
		test_entity := sim_region.entities[i]

		if(test_entity.storage_index != entity.storage_index){
			if(test_entity.collides){
<<<<<<< HEAD
				tower_box := test_entity.bound_box
=======
				tower_box := rl.GetModelBoundingBox(test_entity.model^)
>>>>>>> c60edaae515706ebfb94df981545583986655d4b
				tower_box.min += test_entity.pos
				tower_box.max += test_entity.pos

				box_hit_info := rl.GetRayCollisionBox(ray, tower_box)

				if(box_hit_info.hit && (abs(box_hit_info.distance) <= 1))
				{
					nearest_collision = box_hit_info
					hit = true
				}
			}
		}
	}

	if(!hit){
		entity.pos += delta
		entity.dP = ddp * dt + entity.dP
	}else{
		//entity.pos -= nearest_collision.point
		entity.dP -= (ddp * dt + entity.dP)
		//entity.dP = ddp * dt + entity.dP
	}
}

map_position_to_face ::proc (game_state: ^GameState, pos : vec3)-> vec3{
	face :FaceDirection

	if(game_state.player_index != 0){
		player := game_state.low_entities[game_state.player_index];
		face = player.sim.face_direction
	}

	ret := pos

	switch(face){
	case .LEFT:{
		ret = linalg.vector3f32_swizzle3(pos, .z, .y, .x)
	}
	case .DOWN:{
		ret.z *= -1
	}

	case .UP:{
	}
	case .RIGHT:{
		ret = linalg.vector3f32_swizzle3(pos, .z, .y, .x)
		ret.x *= -1
	}
	}
	return ret
}

update_face_direction :: proc (game_state: ^GameState, entity : ^SimEntity){
	camera := &game_state.camera

	offset := int(entity.face_direction)

	if rl.IsKeyPressed(.DOWN){
		switch(entity.face_direction){
		case .LEFT, .RIGHT:{
			camera.position.x *= -1
		}
		case.UP, .DOWN:{
			camera.position.z *= -1
		}
		}
		offset += 2
	}
	if rl.IsKeyPressed(.LEFT) {
		camera.position = linalg.vector3f32_swizzle3(camera.position, .z, .y, .x)

		#partial switch(entity.face_direction){
			case .UP, .DOWN:{
			camera.position.x *= -1
		}
		}
		offset -= 1
	}
	if(rl.IsKeyPressed(.RIGHT)){
		camera.position = linalg.vector3f32_swizzle3(camera.position, .z, .y, .x)

		#partial switch(entity.face_direction){
			case .LEFT, .RIGHT:{
			camera.position.z *= -1
		}
		}
		offset += 1
	}

	if(offset < 0){
		offset = 3
	}
	if(offset >= len(FaceDirection)){
		offset = offset % len(FaceDirection)
	}
	if(offset != int(entity.face_direction)){
		entity.face_direction = FaceDirection(offset)
	}
}

update_camera_animation :: proc(game_state: ^GameState){
	animation := &game_state.camera_animation

	//check for input

	if rl.IsKeyPressed(.C){

	}

	if !animation.active {

	}
}


