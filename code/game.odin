package main

import "core:mem/virtual"
import rl "vendor:raylib"
import cgltf "vendor:cgltf"
import "core:math/linalg"
import "core:strings"
import gl "vendor:Opengl"

MAX_LIGHTS :: 4

//TODO: Asset struct?
temple_model    : rl.Model
temple_texture  : rl.Texture
brown_floor     : rl.Texture
wall_texture    : rl.Texture
player_model    : rl.Model
wall_model      : rl.Model
grey_wall_model : rl.Model
shader          : rl.Shader
lights          : [MAX_LIGHTS]cgltf.light 

vec3 :: linalg.Vector3f32

GameState :: struct {
	world             : ^World,

	//@depricated
	cam_pos           : WorldPos,
	cam_bounds        : rec3, 
	low_entities      : [10000]LowEntity,
	low_entities_count: u32,
	player_index      : u32,// 0 if player dosen't exist
	initilized        : bool,
	camera            : rl.Camera,

	cam_pos_offset    : vec3,

	//camera_front      : linalg.Vector3f32,
}


chunk_add_base_tiles :: proc(game_state: ^GameState, chunk: ^Chunk, model: ^rl.Model){
	for x in 0..<TILE_COUNT_PER_WIDTH{

		for z in 0..<TILE_COUNT_PER_BREADTH{

			pos : WorldPos
			pos.chunk  = chunk.pos

			//pos.offset = v3_f32{(f32)(x - (TILE_COUNT_PER_WIDTH/2)), 0, (f32)(z - (TILE_COUNT_PER_BREADTH/2))}
			pos.offset = {f32(x), 0, f32(z)}

			add_wall(game_state, pos, model)
		}
	}

}

render_game :: proc(game_state: ^GameState, sim_region: ^SimRegion){
	using rl
	builder        := strings.builder_make()
	player_builder := strings.builder_make()
	world_builder  := strings.builder_make()
	memory_used_builder := strings.builder_make()

	BeginDrawing()
	ClearBackground(Color{10, 110, 80, 55})

	//beginmode3d modes the matrix look at
	prev_pos := game_state.camera.position

	game_state.camera.position  += game_state.cam_pos_offset
	BeginMode3D(game_state.camera)

	for i in 0..<sim_region.entity_count {
		entity := &sim_region.entities[i]
		switch(entity.type){

		case .entity_type_null:{
		}

		case .entity_type_player:{

			rotation := linalg.Vector3f32{}
			angle : f32 = 90

			switch (entity.face_direction){
			case .UP:{
				angle = 0
			}
			case .DOWN:{
				angle = 180
				rotation.y  = 1
			}
			case .LEFT:{
				rotation.y  = 1
			}
			case .RIGHT:{
				rotation.y  = -1
			}
			}

			DrawModelEx(player_model, linalg.Vector3f32(entity.pos), rotation, angle, 1, WHITE)

			strings.write_string(&player_builder, "Player Position, x = ")
			strings.write_f32(&player_builder, entity.pos.x, 'f')
			strings.write_string(&player_builder, ", y = ")
			strings.write_f32(&player_builder, entity.pos.y, 'f')
			strings.write_string(&player_builder, ", z = ")
			strings.write_f32(&player_builder, entity.pos.z, 'f')
		}

		case .entity_type_enemy:{
		}

		case .entity_type_wall:{
			DrawModel(entity.model^, linalg.Vector3f32(entity.pos),1, WHITE)
			//DrawCubeWires(linalg.Vector3f32(entity.pos), 1, 1, 1, WHITE)
		}
		}
	}
	//DrawModel(temple_model, linalg.Vector3f32{0,0,0}, 1, WHITE)

	//DrawModel(wall_model, {}, 1.0, WHITE)
	EndMode3D()

	when true{
		strings.write_string(&builder, "Camera Position, x = ")
		strings.write_f32(&builder, game_state.camera.position.x, 'f')
		strings.write_string(&builder, ", y = ")
		strings.write_f32(&builder, game_state.camera.position.y, 'f')
		strings.write_string(&builder, ", z = ")
		strings.write_f32(&builder, game_state.camera.position.z, 'f')
		DrawText(strings.unsafe_string_to_cstring(strings.to_string(builder)), 30, 30, 20, WHITE)
	}

	strings.write_string(&world_builder, "Chunk count = ");
	strings.write_int(&world_builder, int(game_state.world.chunk_count))

	strings.write_string(&memory_used_builder, "Total Memory used = ");
	strings.write_int(&memory_used_builder, int(platform.arena.total_used))


	DrawFPS(10, 10)
	DrawText(strings.unsafe_string_to_cstring(strings.to_string(player_builder)), 30, 60, 20, WHITE)
	DrawText(strings.unsafe_string_to_cstring(strings.to_string(world_builder)), 30, 90, 20, WHITE)

	DrawText(strings.unsafe_string_to_cstring(strings.to_string(memory_used_builder)), 30, 120, 20, WHITE)

	EndDrawing()
	game_state.camera.position  = prev_pos
}

initilize_light :: proc(){
	using rl;

	shader = LoadShader("../code/vert.glsl", "../code/frag.glsl")

	//Get some required shader locations
	shader.locs[ShaderLocationIndex.VECTOR_VIEW] = GetShaderLocation(shader, "viewPos")

	//some basic lightning
	ambientLoc := GetShaderLocation(shader, "ambient")

	ambient :[4]f32= {0.1, 0.1, 0.1, 1.0}
	SetShaderValue(shader, ShaderLocationIndex(ambientLoc), cast(rawptr)&ambient[0], .VEC4)
}

update_game :: proc(){
	game_state := cast(^GameState)platform.arena.curr_block.base;

	if !game_state.initilized {

		game_state.initilized = true;
		game_state.low_entities_count = 0;
		game_state.cam_bounds.min  = v3_f32{-100, -4, -100}
		game_state.cam_bounds.max  = v3_f32{ 100,  5,  100}

		//TODO: load all this from config file and probably change it on file changed 
		game_state.camera.position   = {0.0, 10,  -10} //cam pos
		//game_state.camera_front      = {0.0, -1, 1.0} 
		//game_state.camera.target     = game_state.camera.position + game_state.camera_front      //camera looking at position
		game_state.camera.up         = {0.0, 1.0, 0.0} //camera up vector 
		game_state.camera.fovy       = 45.0
		game_state.camera.projection = .PERSPECTIVE 

		initilize_light();

		temple_model = rl.LoadModel("../data/turrent.glb")
		//temple_model.materials[0].shader = shader
		//texture := rl.LoadTexture("../data/turret_diffuse.png")
		//rl.GenTextureMipmaps(&texture)
		//rl.SetTextureFilter(texture, .ANISOTROPIC_16X)

		//temple_model.materials[0].maps[rl.MaterialMapIndex.ALBEDO].texture = texture

		player_model = rl.LoadModel("../data/security_officer/scene.gltf")
		player_model.materials[0].shader = shader


		using cgltf

		wall_model = rl.LoadModel("../data/cube.glb")
		grey_wall_model = rl.LoadModel("../data/grey_cube.glb")

		wall_texture = rl.LoadTexture("../data/tex_wall.png")

		rl.GenTextureMipmaps(&wall_texture)
		rl.SetTextureFilter(wall_texture, .TRILINEAR)

		brown_floor = rl.LoadTexture("../data/brown_floor.png")
		rl.GenTextureMipmaps(&brown_floor)
		rl.SetTextureFilter(brown_floor, .TRILINEAR)

		//wall_model.materials[0].maps[rl.MaterialMapIndex.ALBEDO].texture = texture

		add_low_entity(game_state, .entity_type_null, {})

		
		initilize_world(game_state)

		player_pos :WorldPos 
		player_pos.offset = {3,1, 1}
		game_state.player_index = add_player(game_state, player_pos).entity_index


		chunk := get_world_chunk(game_state.world, {0,0,0}, &platform.arena)
		chunk_add_base_tiles(game_state, chunk, &grey_wall_model)

		chunk = get_world_chunk(game_state.world, {0,0,1}, &platform.arena)
		chunk_add_base_tiles(game_state, chunk, &wall_model)


		chunk = get_world_chunk(game_state.world, {1,0,0}, &platform.arena)
		chunk_add_base_tiles(game_state, chunk, &wall_model)

		chunk = get_world_chunk(game_state.world, {1,1,1}, &platform.arena)
		chunk_add_base_tiles(game_state, chunk, &grey_wall_model)

	}

	//begin and end sim
	//TODO: do this on temporary memory?
	sim_memory := virtual.arena_temp_begin(&platform.temp_arena)

	//currently the camera pos is the player pos but we need to make it more flexible later
	cam_pos : WorldPos = {}

	if(game_state.player_index != 0){
		player := game_state.low_entities[game_state.player_index];
		cam_pos = player.pos
	}

	sim_region := begin_sim(sim_memory.arena, game_state, cam_pos, game_state.cam_bounds)


	//TODO add simulation code

	//maybe this could be just v2? and some jump code?

	player_ddp : v3_f32

	camera := &game_state.camera
	//rl.UpdateCamera(camera, .THIRD_PERSON)
	//-= rl.GetMouseWheelMove()/10 * vec3{10, 10, 0} //game_state.camera_front
	//camera.target     = game_state.camera.position + game_state.camera_front      //camera looking at position

	speed : f32 = .1

	if rl.IsKeyDown(.S) {
		player_ddp.z = -1;
		//camera.position -= speed * camera.target
		//camera.target     = game_state.camera.position + game_state.camera_front      //camera looking at position
	}
	if rl.IsKeyDown(.W) {
		player_ddp.z = 1;
		//camera.position += speed* camera.target
		//camera.target     = game_state.camera.position + game_state.camera_front      //camera looking at position
	}
	if rl.IsKeyDown(.A) {
		player_ddp.x = 1;
	}
	if rl.IsKeyDown(.D) {
		player_ddp.x = -1;
	}

	//update jump

	for entity, i in &sim_region.entities{
		if u32(i) >= sim_region.entity_count { break}

		#partial switch entity.type {
			case .entity_type_player:{
				using linalg
				radius : f64 = 20
				cam_x  := f32(sin(1.0) * radius)
				cam_z  := f32(cos(1.0) * radius)

				if(rl.IsKeyPressed(.UP)){
					entity.face_direction = .UP
				}
				if(rl.IsKeyPressed(.DOWN)){
					entity.face_direction = .DOWN
				}
				if(rl.IsKeyPressed(.LEFT)){
					entity.face_direction = .LEFT
					//camera.position -= vec3{cam_x, 0, cam_z}
					game_state.cam_pos_offset  = vec3{cam_x, 0, cam_z} 
				}
				if(rl.IsKeyPressed(.RIGHT)){
					entity.face_direction = .RIGHT
					//the rotate thing

					//view := matrix4_look_at_f32(vec3{cam_x, 0, cam_z} + entity.pos, entity.pos, vec3{0, 1, 0})

					//camera.position += 

					
					//rl.rlMultMatrixf(cast([^]f32)&view[0])
					game_state.cam_pos_offset  = vec3{cam_x, 0, cam_z} 
						
				}

				low := &game_state.low_entities[entity.storage_index]
				spec := default_move_spec()
				spec.unit_max_accel_vector = true
				spec.speed = 30.0
				spec.drag  = 8.0
				move_entity(game_state, sim_region, &entity, 0.01667, &spec, player_ddp)
				//game_state.camera_front      =  cast(linalg.Vector3f32)(entity.pos)
			}
		}
	}
	

	end_sim(sim_region, game_state)

	render_game(game_state, sim_region)
	virtual.arena_temp_end(sim_memory)

}

