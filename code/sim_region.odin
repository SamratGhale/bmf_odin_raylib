package main

import "core:mem/virtual"
import "core:math/linalg"

SimRegion :: struct {
	entity_count : u32,
	bounds       : rec3,
	center       : WorldPos,
	world        : ^World,
	sim_arena    : ^virtual.Arena,
	entities     : [10000]SimEntity,
}

add_entity_to_sim :: proc(
	game_state: ^GameState,
	region: ^SimRegion,
	low_index: u32,
	low: ^LowEntity,
	entity_rel_pos: vec3,
) -> ^SimEntity {

	assert(low_index != 0)

	entity := &region.entities[region.entity_count]
	region.entity_count += 1

	assert(low != nil) //?

	entity^ = low.sim
	add_flag(&low.sim.flags, u32(EntityFlags.entity_flag_simming))

	entity.storage_index = low_index
	entity.pos = entity_rel_pos

	return entity
}

//what is the position of middle tile of chunk with respect to the current player

curr_chunk_offset :: proc(game_state: ^GameState) -> vec3{
	player: ^LowEntity;
	if(game_state.player_index != 0){
		player = &game_state.low_entities[game_state.player_index];
	}
	center_tile_pos : WorldPos 
	center_tile_pos.chunk = player.pos.chunk

	//center_tile_pos = map_into_world_pos(game_state.world, player.pos, )

	//player_offset_from_chunk := subtract(game_state.world, center_tile_pos, player.pos)

	entity_sim_space := subtract(game_state.world, center_tile_pos, {})

	
	return entity_sim_space
}

begin_sim :: proc(sim_arena: ^virtual.Arena, game_state: ^GameState, center: WorldPos, bounds: rec3)-> ^SimRegion{

	world := game_state.world
	
	sim_region              := push_struct(sim_arena, SimRegion)
	sim_region.world        = world
	sim_region.sim_arena    = sim_arena
	sim_region.center       = center
	sim_region.bounds       = bounds
	sim_region.entity_count = 0

	min_chunk_pos := map_into_world_pos(world, sim_region.center, vec3(bounds[0])).chunk
	max_chunk_pos := map_into_world_pos(world, sim_region.center, vec3(bounds[1])).chunk

	for x in min_chunk_pos.x ..= max_chunk_pos.x {
		for y in min_chunk_pos.y ..= max_chunk_pos.y{

			for z in min_chunk_pos.z ..= max_chunk_pos.z {
				chunk := get_world_chunk(world, vec3i{i32(x), i32(y), i32(z)}, nil)

				for chunk != nil{
					node := chunk.node

					for node != nil && node.entity_index != 0{
						entity := &game_state.low_entities[node.entity_index]

						if(!is_flag_set(entity.sim.flags, u32(EntityFlags.entity_flag_simming)))
						{
							entity_sim_space := subtract(world, entity.pos, sim_region.center)
							add_entity_to_sim(game_state, sim_region, node.entity_index, entity, entity_sim_space)
						}
						node = node.next
					}
					chunk = chunk.next
				}
			}
		}
	}
	return sim_region
}

end_sim :: proc(region: ^SimRegion, game_state : ^GameState) {

	for i in 0..< region.entity_count{
		entity := &region.entities[i]
		low := &game_state.low_entities[entity.storage_index]
		low.sim = entity^

		new_world_pos := map_into_world_pos(region.world, region.center, entity.pos)
		old_pos       := low.pos

		if old_pos.chunk != new_world_pos.chunk || old_pos.offset != new_world_pos.offset{

			change_entity_location(&platform.arena, game_state.world,
								   entity.storage_index, low, new_world_pos)
		}
	}
}


is_in_rectangle :: proc (rect: rec3, test: vec3)-> bool
{
	result := ((test.x < rect[1].x && test.y < rect[1].y) &&
				   (test.x >= rect[0].x && test.y >= rect[0].y) && 
				   (test.z >= rect[0].x && test.z >= rect[0].z))
	return result
}

