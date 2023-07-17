package main

import "core:c"
import "core:runtime"
import "core:mem/virtual"
import "core:math"
import "core:math/linalg"
import "core:math/fixed"
import rl "vendor:raylib"

TILE_CHUNK_UNINITILIZED :: c.INT32_MAX

TILE_COUNT_PER_WIDTH   :: 16 //x axis
TILE_COUNT_PER_HEIGHT  :: 5  //y axis
TILE_COUNT_PER_BREADTH :: 10 //z axis

WorldPos :: struct {
	chunk:  v3_i32,
	offset: v3_f32,
}


EntityNode :: struct {
	entity_index: u32,
	next:         ^EntityNode,
}

Chunk :: struct {
	entity_count : u32,
	pos:  v3_i32,
	node: ^EntityNode,
	next: ^Chunk,
}

World :: struct {
	chunk_size_in_meters: v3_f32,
	chunk_hash:           [128]Chunk,
	chunk_count:          u32 , //only for debug
	meters_to_pixels:     u32,
}


//HEADER END

push_struct :: proc (arena: ^virtual.Arena, $T: typeid) -> ^T{
	data, ok := virtual.arena_alloc(arena, size_of(T), 8);

	if ok == runtime.Allocator_Error.None {
		return cast(^T)&data[0];
	}else{
		print("Error allocating ")
		return nil;
	}
}


//TODO: Check if the next, node and entity_count is zero by default
add_new_chunk :: proc(
	arena: ^virtual.Arena,
	world: ^World,
	head: ^Chunk,
	chunk_pos: v3_i32,
) -> (
	new_chunk: ^Chunk,
) {

	new_chunk = push_struct(arena, Chunk);
	new_chunk.pos = chunk_pos
	new_chunk.next = nil

	new_chunk.node = push_struct(arena, EntityNode); 
	new_chunk.entity_count = 0

	curr := head
	for curr.next != nil {
		curr = curr.next
	}
	curr.next = new_chunk
	//initilize_chunk_tiles(world, new_chunk)
	world.chunk_count += 1
	return
}

/* 
  Basically a hashmap indexing,
  Additionally if there's no chunk then it adds one
  */
get_world_chunk :: proc(
	world: ^World,
	pos: v3_i32,
	arena: ^virtual.Arena = nil,
) -> ^Chunk {

	hash := 19 * abs(pos.x) + 7 + abs(pos.z)
	hash_slot := hash % (len(world.chunk_hash) - 1)

	head := &world.chunk_hash[hash_slot]
	chunk := head

	for chunk != nil {
		if pos == chunk.pos {
			break
		}
		if chunk.pos.x == TILE_CHUNK_UNINITILIZED {
			chunk.pos = pos
			chunk.entity_count = 0
			break
		}
		chunk = chunk.next
	}
	if (chunk == nil) && (arena != nil) {
		chunk = add_new_chunk(arena, world, head, pos)
	}
	return chunk
}

change_entity_location :: proc(
	arena: ^virtual.Arena,
	world: ^World,
	entity_index: u32,
	entity: ^LowEntity,
	new_p: WorldPos,
) {

	//removing the old entity from the chunk

	if entity_index == 0 {return}

	old_p := entity.pos

	if new_p.chunk.x != TILE_CHUNK_UNINITILIZED {
		if old_p.chunk.x != TILE_CHUNK_UNINITILIZED {
			chunk := get_world_chunk(world, old_p.chunk, arena)
			assert(chunk != nil)
			assert(chunk.node != nil)


			if (new_p.chunk != old_p.chunk) {
				node := chunk.node
				if node.entity_index == entity_index {
					chunk.node = node.next
				} else {

					curr := node
					for curr.next != nil && curr.entity_index != 0 {
						if curr.next.entity_index == entity_index {
							node = curr.next
							curr.next = curr.next.next
							break
						} else {
							curr = curr.next
						}
					}
				}
			}
		}

		//add to new pos's chunk, adds to the head

		if (new_p.chunk!= old_p.chunk) {

			chunk := get_world_chunk(world, new_p.chunk, arena)

			curr := chunk.node

			found := false

			for curr != nil {
				if curr.entity_index == entity_index {
					found = true
					break
				}
				curr = curr.next
			}

			if (!found) {
				node := push_struct(arena, EntityNode)
				node.entity_index = entity_index
				node.next = chunk.node
				chunk.node = node
			}
		}

		entity.pos = new_p
	}
}

initilize_world :: proc(game: ^GameState) {

	//this should probably always be true
	if game.world == nil{
		game.world = push_struct(&platform.arena, World)
	}

	world := game.world;

	world.chunk_size_in_meters = v3_f32{f32(TILE_COUNT_PER_WIDTH), f32(TILE_COUNT_PER_HEIGHT), f32(TILE_COUNT_PER_BREADTH)};

	world.chunk_count = len(world.chunk_hash)

	for chunk in &world.chunk_hash
	{
		chunk        = {}
		chunk.pos.x  = TILE_CHUNK_UNINITILIZED;
	}
}



/*
Floor:: proc(Real32: f32 ) ->f32
{
    // TODO(casey): Do we want to forgo the use of SSE 4.1?
    Result : = sse2._mm_cvtss_f32(sse2._mm_floor_ss(sse2._mm_setzero_ps(), sse2._mm_set_ss(Real32)))
    return(Result);
}
*/

adjust_world_position :: proc(world: ^World, chunk_pos: ^i32, offset: ^f32, csim: f32) {
	if(abs(offset^)  > csim){
		extra_offset :i32= 0;
		if(offset^ > 0){
			extra_offset = i32(linalg.floor(offset^ / csim))
		}else{
			extra_offset = i32(linalg.ceil(offset^ / csim))
		}
		chunk_pos^   += extra_offset
		offset^      -= f32(f32(extra_offset) * csim)
	}
}


map_into_world_pos :: proc(world: ^World, origin: WorldPos, offset: v3_f32) -> WorldPos
{

	csim := world.chunk_size_in_meters
	result := origin
	result.offset += offset

	adjust_world_position(world, &result.chunk.x, &result.offset.x, csim.x)
	adjust_world_position(world, &result.chunk.y, &result.offset.y, csim.y)
	adjust_world_position(world, &result.chunk.z, &result.offset.z, csim.z)
	return result
}

subtract :: proc(world: ^World, a: WorldPos, b: WorldPos) -> v3_f32 {
	result: v3_f32

	result.y = f32(a.chunk.y) - f32(b.chunk.y)
	result.z = f32(a.chunk.z) - f32(b.chunk.z)
	result.x = f32(a.chunk.x) - f32(b.chunk.x)

	result = result * world.chunk_size_in_meters
	result = result + (a.offset - b.offset)
	return result
}


