package main

import "core:mem/virtual"
import rl "vendor:raylib"
import "core:math/linalg"
import "core:reflect"
import "core:strings"
import "core:thread"

//TODO: Asset struct?
<<<<<<< HEAD
=======
temple_model    : rl.Model
temple_texture  : rl.Texture
brown_floor     : rl.Texture
wall_texture    : rl.Texture
player_model    : rl.Model
wall_model      : rl.Model
grey_wall_model : rl.Model
shader          : rl.Shader
//lights          : [MAX_LIGHTS]cgltf.light 
shraddh_ko_ghar : rl.Model
grass           : rl.Model
plant           : rl.Model
stone           : rl.Model

lights          : [MAX_LIGHTS]Light

debug_font      : rl.Font
debug_builder   : strings.Builder
grimchild_model : rl.Model

player_animation : [^]rl.ModelAnimation
player_anim_frame_counter : i32
player_anim_count: u32
>>>>>>> c60edaae515706ebfb94df981545583986655d4b


Animation :: struct {
	active    : bool,
	forced    : bool,
	dest      : vec3,
	src       : vec3,
	ddp       : vec3,
	completed : u32,
}

GameCameraMode :: enum {
	PLAYER_ZOOMED,
	PLAYER_NOZOOMED,
	GRID,
	FREE_MODE, //probably not that useful
}

GameState :: struct {
	world              : ^World,
	low_entities       : [100000]LowEntity,
	low_entities_count : u32,
	player_index       : u32,// 0 if player dosen't exist
	initilized         : bool,
	cam_pos            : WorldPos,
	cam_bounds         : rec3, 
	camera             : rl.Camera,
	camera_animation   : Animation,
	camera_mode        : GameCameraMode,
	view_debug         : bool,
	asset              : Asset,
}

chunk_add_base_tiles :: proc(game_state: ^GameState, chunk: ^Chunk, model: AssetTypeModel){
	for x in 0..<TILE_COUNT_PER_WIDTH{

		for z in 0..<TILE_COUNT_PER_BREADTH{


			pos : WorldPos
			pos.chunk  = chunk.pos

			pos.offset = {f32(x), 0, f32(z)}

			add_wall(game_state, pos, model)

			if((x == TILE_COUNT_PER_WIDTH-1 || z == TILE_COUNT_PER_BREADTH-1) ||(x == 0|| z == 0)){

				if((x == TILE_COUNT_PER_WIDTH-1 && z == TILE_COUNT_PER_BREADTH-1) ||(x == 0 && z == 0)){
					pos.offset = {f32(x), 2, f32(z)}
<<<<<<< HEAD
					add_stone(game_state, pos, .STONE)
					pos.offset = {f32(x), 2, f32(z)}
					add_stone(game_state, pos, .STONE)
=======
					add_stone(game_state, pos, &stone)
					//pos.offset = {f32(x), 2, f32(z)}
					//add_stone(game_state, pos, &stone)
>>>>>>> c60edaae515706ebfb94df981545583986655d4b
				} else{
					pos.offset = {f32(x), 1, f32(z)}
					add_wall(game_state, pos, model)
					pos.offset = {f32(x), 2, f32(z)}
					add_wall(game_state, pos, model)
				}
			}
		}
	}
}

display_debug :: proc(game_state: ^GameState){
	using strings
	debug_builder := strings.builder_make()
	debug_font    := game_state.asset.debug_font

	if(game_state.view_debug){

		player := game_state.low_entities[game_state.player_index];
		write_string(&debug_builder, "\nPlayer Chunk = ")
		write_int(&debug_builder, int(player.pos.chunk.x))
		write_string(&debug_builder, ",")
		write_int(&debug_builder, int(player.pos.chunk.y))
		write_string(&debug_builder, ",")
		write_int(&debug_builder, int(player.pos.chunk.z))

		write_string(&debug_builder, "   Offset = ")
		write_f32(&debug_builder, (player.pos.offset.x),'f')
		write_string(&debug_builder, ",")
		write_f32(&debug_builder, (player.pos.offset.y),'f')
		write_string(&debug_builder, ",")
		write_f32(&debug_builder, (player.pos.offset.z),'f')

		write_string(&debug_builder, "\nCamera Mode = ")
		write_string(&debug_builder, reflect.enum_string(game_state.camera_mode))

		write_string(&debug_builder, "\nPlayer Face Direction = ")
		write_string(&debug_builder, reflect.enum_string(player.sim.face_direction))

		write_string(&debug_builder, "\nCamera Position, x = ")
		write_f32(&debug_builder, game_state.camera.position.x, 'f')
		write_string(&debug_builder, ", y = ")
		write_f32(&debug_builder, game_state.camera.position.y, 'f')
		write_string(&debug_builder, ", z = ")
		write_f32(&debug_builder, game_state.camera.position.z, 'f')
		write_string(&debug_builder, "\nChunk count = ");
		write_int(&debug_builder, int(game_state.world.chunk_count))
		write_string(&debug_builder, "\nTotal Memory used = ");
		write_int(&debug_builder, int(platform.arena.total_used))
		write_string(&debug_builder, " Bytes")
		write_string(&debug_builder, "\nTotal low entities = ");
		write_int(&debug_builder, int(game_state.low_entities_count))

		rl.DrawTextEx(debug_font, unsafe_string_to_cstring(to_string(debug_builder)), {}, 20, 0, rl.WHITE)
		builder_destroy(&debug_builder);
		debug_builder = builder_make(); 
	}
}

render_game :: proc(game_state: ^GameState, sim_region: ^SimRegion){

	menu_state := cast(^MenuState)(uintptr(platform.arena.curr_block.base));
	using rl
	using strings

	using game_state.asset
	//TODO: use only one string builder
	menu_state.seconds += GetFrameTime()
	SetShaderValue(menu_state.shader, auto_cast(menu_state.secondsLoc), &menu_state.seconds, .FLOAT);

	BeginDrawing()
	ClearBackground(Color{0, 0, 0, 0})

	//beginmode3d modes the matrix look at
	BeginShaderMode(menu_state.shader)


	DrawTexturePro(
		menu_state.space_texture,
		Rectangle{ 0, 0, f32(menu_state.space_texture.width), f32(menu_state.space_texture.height) },
		Rectangle{ 0, 0, f32(GetScreenWidth()), f32(GetScreenHeight()) },
		{ 0, 0 },
		0,
		WHITE);
	EndShaderMode()


	BeginMode3D(game_state.camera)
	for i in 0..<sim_region.entity_count {
		entity := &sim_region.entities[i]
		#partial switch(entity.type){

			case .entity_type_player:{

				rotation := linalg.Vector3f32{}
				angle : f32 = 0
				rotation.y  = 1
				#partial switch (entity.face_direction){
					case .DOWN:{
						angle = 180
					}
					case .LEFT:{
						angle = 90
					}
					case .RIGHT:{
						angle = -90
					}
				}
				light_pos := entity.pos
				light_pos.y += 2

				lights[entity.light_index].pos    = light_pos
<<<<<<< HEAD
				DrawModelEx(models[entity.model], linalg.Vector3f32(entity.pos), rotation, angle, 1.5, WHITE)
			}

			case .entity_type_wall:{
				DrawModel(models[entity.model], entity.pos, 1, WHITE)
			}
			case .entity_type_stone:{
				DrawModel(models[entity.model], entity.pos, 1, WHITE)
=======
				DrawModelEx(entity.model^, linalg.Vector3f32(entity.pos), rotation, angle, 1.5, WHITE)
			}

			case .entity_type_wall:{
				DrawModel(entity.model^, entity.pos, 1, WHITE)
			}
			case .entity_type_stone:{
				DrawModel(entity.model^, entity.pos, 1, WHITE)
>>>>>>> c60edaae515706ebfb94df981545583986655d4b
			}
			case .entity_type_grimchild:{
				player_anim_frame_counter += 1;
				UpdateModelAnimation(models[entity.model], player_animation[0], player_anim_frame_counter)
				if(player_anim_frame_counter > player_animation[0].frameCount){
					player_anim_frame_counter = 0
				}

<<<<<<< HEAD
				DrawModel(models[entity.model], entity.pos, 5, WHITE)
				light_pos := entity.pos
				light_pos.y += 2

				lights[entity.light_index].pos    = light_pos
				lights[entity.light_index].target = light_pos
			}

			case .entity_type_house:{
				//print(models[entity.model.])
				DrawModel(models[entity.model], entity.pos, 1, WHITE)
=======
				DrawModel(entity.model^, entity.pos, 5, WHITE)
				light_pos := entity.pos
				light_pos.y += 2

				//lights[entity.light_index].pos    = light_pos
				//lights[entity.light_index].target = light_pos
			}

			case .entity_type_house:{
				DrawModel(entity.model^, entity.pos, 1, WHITE)
>>>>>>> c60edaae515706ebfb94df981545583986655d4b
			}
		}
	}

	for i in 0..< MAX_LIGHTS
	{
		if (lights[i].enabled) {
			//DrawSphereEx(lights[i].pos, .2, 100, 100, lights[i].color)
		}
		else {
			//DrawSphereWires(lights[i].pos, .2, 8, 8, lights[i].color)
			//DrawSphereEx(lights[i].pos, .2, 8, 8, lights[i].color)
			//DrawSphereEx({3, 0, 0}, 20.0, 8, 8, {1,0,0,1})
			//DrawSphere({3, 0, 0}, 20.0, {1,1,1,1})
		}
	}


	EndMode3D()
	display_debug(game_state)
	EndDrawing()
}

initilize_light :: proc(){
	using rl;

	game_state := cast(^GameState)(uintptr(platform.arena.curr_block.base) + size_of(MenuState));
	using game_state.asset
	shader = LoadShader("../code/light_vertex.glsl", "../code/light_frag.glsl")


	//Get some required shader locations
	shader.locs[ShaderLocationIndex(.VECTOR_VIEW)] = GetShaderLocation(shader, "viewPos")

	//some basic lightning
	ambientLoc := GetShaderLocation(shader, "ambient")

	ambient :vec4= {0.01, 0.01, 0.01, 0.5}
	SetShaderValue(shader, ShaderLocationIndex(ambientLoc), &ambient[0], .VEC4)

	for model in &models{
		model.materials[0].shader = shader
		model.materials[1].shader = shader
	}
	/*
	player_model.materials[0].shader = shader
	wall_model.materials[0].shader = shader
	grey_wall_model.materials[0].shader = shader
	player_model.materials[1].shader = shader
	wall_model.materials[1].shader = shader
	grey_wall_model.materials[1].shader = shader
	grimchild_model.materials[0].shader = shader
	grimchild_model.materials[1].shader = shader
<<<<<<< HEAD
	*/
=======
>>>>>>> c60edaae515706ebfb94df981545583986655d4b
}

initilize_game :: proc(){
	game_state := cast(^GameState)(uintptr(platform.arena.curr_block.base) + size_of(MenuState));

	if !game_state.initilized {
		using rl

		game_state.view_debug = true

		game_state.initilized = true;
		game_state.low_entities_count = 0;
		game_state.cam_bounds[0] = {-100, -10, -100}
		game_state.cam_bounds[1] = { 100,  10,  100}

		//TODO: load all this from config file and probably change it on file changed 
		game_state.camera.position   = {0.0, 7,  -10} //cam pos
		game_state.camera.up         = {0.0, 1.0, 0.0} //camera up vector 
		game_state.camera.fovy       = 45.0
		game_state.camera.projection = .PERSPECTIVE 


<<<<<<< HEAD
		add_low_entity(game_state, .entity_type_null, {})
		initilize_world(game_state)
		//initilize_light();
=======
		temple_model = LoadModel("../data/turrent.glb")
		grass        = LoadModel("../data/Grass.glb")
		player_model = LoadModel("../data/security_officer/untitled.glb")
		grimchild_model = LoadModel("../data/hollow.glb")

		player_animation = LoadModelAnimations("../data/hollow.glb", &player_anim_count)
		player_anim_frame_counter = 0


		//using cgltf

		wall_model = LoadModel("../data/cube.glb")
		grey_wall_model = LoadModel("../data/grey_cube.glb")


		//wall_model  = LoadModelFromMesh(GenMeshPlane(10.0, 10.0, 3, 3));
		//grey_wall_model  = LoadModelFromMesh(GenMeshPlane(10.0, 10.0, 3, 3));


		shraddh_ko_ghar = LoadModel("../data/shradd_house.glb")
		//plant = LoadModel("../data/plant.glb")
		stone = LoadModel("../data/rock.glb")

		GenTextureMipmaps(&wall_texture)
		SetTextureFilter(wall_texture, .TRILINEAR)

		GenTextureMipmaps(&brown_floor)

		SetTextureFilter(brown_floor, .TRILINEAR)

		add_low_entity(game_state, .entity_type_null, {})
		initilize_world(game_state)
		initilize_light();
>>>>>>> c60edaae515706ebfb94df981545583986655d4b

		player_pos :WorldPos 
		player_pos.offset = {TILE_COUNT_PER_WIDTH/2, 1 , TILE_COUNT_PER_BREADTH/2}
		game_state.player_index = add_player(game_state, player_pos).entity_index

		player_pos.offset = {2, 1 , 2}
		add_grimchild(game_state, player_pos)
		player_pos.offset = {10,1,10}
		add_grimchild(game_state, player_pos)
<<<<<<< HEAD
=======

		//player_pos.chunk = {0,1,1}
		player_pos.offset = {3,1,11}
		//add_stone(game_state, player_pos, &stone)
		player_pos.offset = {2,1,10}
		//add_stone(game_state, player_pos, &stone)
		player_pos.offset = {1,1,9}
		//add_stone(game_state, player_pos, &stone)


>>>>>>> c60edaae515706ebfb94df981545583986655d4b

		chunk := get_world_chunk(game_state.world, {0,0,0}, &platform.arena)
		chunk_add_base_tiles(game_state, chunk, .GREY_WALL)

		chunk = get_world_chunk(game_state.world, {-1,0,0}, &platform.arena)
		chunk_add_base_tiles(game_state, chunk, .WALL)

		chunk = get_world_chunk(game_state.world, {-3,2,4}, &platform.arena)
		chunk_add_base_tiles(game_state, chunk, .WALL)

<<<<<<< HEAD
=======
		/*
		chunk = get_world_chunk(game_state.world, {-2,0,0}, &platform.arena)
		chunk_add_base_tiles(game_state, chunk, &wall_model)

		chunk = get_world_chunk(game_state.world, {-2,0,-1}, &platform.arena)
		chunk_add_base_tiles(game_state, chunk, &wall_model)

		chunk = get_world_chunk(game_state.world, {-2,0,0}, &platform.arena)
		chunk_add_base_tiles(game_state, chunk, &wall_model)

		chunk = get_world_chunk(game_state.world, {0,1,1}, &platform.arena)
		chunk_add_base_tiles(game_state, chunk, &grey_wall_model)

		chunk = get_world_chunk(game_state.world, {0,0,1}, &platform.arena)
		chunk_add_base_tiles(game_state, chunk, &wall_model)


		chunk = get_world_chunk(game_state.world, {1,0,0}, &platform.arena)
		chunk_add_base_tiles(game_state, chunk, &wall_model)

		chunk = get_world_chunk(game_state.world, {1,1,1}, &platform.arena)
		chunk_add_base_tiles(game_state, chunk, &grey_wall_model)

		chunk = get_world_chunk(game_state.world, {2,1,1}, &platform.arena)
		chunk_add_base_tiles(game_state, chunk, &grey_wall_model)
>>>>>>> c60edaae515706ebfb94df981545583986655d4b

		*/

		house_pos : WorldPos = {}
		house_pos.chunk = {-3, 2, 4}
<<<<<<< HEAD
		//add_house(game_state, house_pos, .SHRADDHA_KO_GHAR)
		print("Initilized game ")
=======
		add_house(game_state, house_pos, &shraddh_ko_ghar)

		debug_font = LoadFontEx("../data/DroidSansMono.ttf", 100, nil, 256)
		debug_builder = strings.builder_make(); 

>>>>>>> c60edaae515706ebfb94df981545583986655d4b
	}

}

update_game :: proc(){
	game_state := cast(^GameState)(uintptr(platform.arena.curr_block.base) + size_of(MenuState));

	using rl

	if !game_state.initilized{
		load_all_asset()
		initilize_game()
	}
	//begin and end sim
	//TODO: do this on temporary memory?
	sim_memory := virtual.arena_temp_begin(&platform.temp_arena)

	//currently the camera pos is the player pos but we need to make it more flexible later


	
	camera := &game_state.camera
	if(game_state.camera_mode != .FREE_MODE){

		player := game_state.low_entities[game_state.player_index];

		if(game_state.camera_mode == .GRID){
			offset :vec3= {(f32)(TILE_COUNT_PER_WIDTH/2), 0, (f32)(TILE_COUNT_PER_BREADTH/2)}

			game_state.cam_pos = player.pos
			game_state.cam_pos.offset = offset
			//lights[0].target = offset
		}else{
			game_state.cam_pos = player.pos
		}
		//SetShaderValue(shader, ShaderLocationIndex.VECTOR_VIEW, &player.sim.pos[0], .VEC3)
	}else{
	}
	for i in 0..< total_light_count{
<<<<<<< HEAD
		//update_light_values(shader, &lights[i])
=======
		update_light_values(shader, &lights[i])
>>>>>>> c60edaae515706ebfb94df981545583986655d4b
	}


	sim_region := begin_sim(sim_memory.arena, game_state, game_state.cam_pos, game_state.cam_bounds)


	//TODO add simulation code

	//maybe this could be just v2? and some jump code?

	player_ddp : vec3

	if(game_state.camera_mode == .FREE_MODE){
		UpdateCamera(camera, .FREE)
	}
	speed : f32 = .1

	if IsKeyPressed(.ESCAPE){
		platform.game_mode = .GAME_MODE_MENU
	}

	if IsKeyDown(.S) {
		player_ddp.z = -1;
	}
	if IsKeyDown(.W) {
		player_ddp.z = 1;
	}
	if IsKeyDown(.A) {
		player_ddp.x = 1;
	}
	if IsKeyDown(.D) {
		player_ddp.x = -1;
	}


	if IsKeyPressed(.F1){
		game_state.view_debug = !game_state.view_debug
	}

	if IsKeyDown(.LEFT_ALT) && IsKeyPressed(.C){
		camera.target = {}
		if(int(game_state.camera_mode) + 1 >= len(GameCameraMode)){
			game_state.camera_mode = GameCameraMode(0)
		}else{
			game_state.camera_mode = GameCameraMode(int(game_state.camera_mode) + 1)
		}
		switch(game_state.camera_mode){
			case .PLAYER_ZOOMED:{
			game_state.camera.position   = map_position_to_face(game_state, vec3{0.0, 10,  -10}) //cam pos
		}
		case .PLAYER_NOZOOMED:{
			game_state.camera.position   = map_position_to_face(game_state, vec3{0.0, 20,  -20}) //cam pos
		}
		case .GRID:{
		}
		case .FREE_MODE:{
		}
	}
}

	//update jump

	if(rl.IsKeyPressed(.SPACE)){
		rl.ToggleFullscreen()
		if(rl.IsWindowFullscreen()){
			rl.SetWindowSize(1920, 1080)
		}else{
			rl.SetWindowSize(screen_width, screen_height)
		}
	}

<<<<<<< HEAD
	for &entity, i in sim_region.entities{
=======
	for entity, i in &sim_region.entities{
>>>>>>> c60edaae515706ebfb94df981545583986655d4b
		if u32(i) >= sim_region.entity_count { break}

		#partial switch entity.type {
			case .entity_type_player:{


				if(game_state.camera_mode != .FREE_MODE){
					update_face_direction(game_state, &entity)
					low := &game_state.low_entities[entity.storage_index]
					spec := default_move_spec()
					spec.unit_max_accel_vector = true
					spec.speed = 170.0
					spec.drag  = 10.0
					move_entity(game_state, sim_region, &entity, 0.01667, &spec, player_ddp)
				}
				//game_state.camera_front      =  cast(linalg.Vector3f32)(entity.pos)
			}
		}
	}
	
	end_sim(sim_region, game_state)
	render_game(game_state, sim_region)
	virtual.arena_temp_end(sim_memory)
}

