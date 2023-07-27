package main

import rl "vendor:raylib"
import "core:strings"


AssetTypeModel :: enum {
	PLAYER,
	WALL,
	GREY_WALL,
	SHRADDHA_KO_GHAR,
	GRASS,
	STONE,
	GRIMCHILD,
}

Asset :: struct{

	models   :[AssetTypeModel]rl.Model,

	shader          : rl.Shader,
	player_animation : [^]rl.ModelAnimation,

	lights          : [MAX_LIGHTS]Light,

	debug_font      : rl.Font,
	debug_builder   : strings.Builder,

	player_anim_frame_counter : i32,
	player_anim_count: u32,

}

load_all_asset :: proc(){
	//plat := cast(^PlatformState)platform_raw
	//if(platform.asset.loaded < len(platform.asset.models)){

	//}
	//using platform.asset

	game_state := cast(^GameState)(uintptr(platform.arena.curr_block.base) + size_of(MenuState));
	models := &game_state.asset.models
	using rl

		/*
		switch(AssetTypeModel(loaded)){
			case .GRASS:{
				models[.GRASS]     = LoadModel("../data/Grass.glb")
			}
			case .PLAYER:{
				models[.PLAYER]    = LoadModel("../data/security_officer/untitled.glb")
				player_animation = LoadModelAnimations("../data/hollow.glb", &player_anim_count)
				player_anim_frame_counter = 0
				debug_builder = strings.builder_make(); 
			}
			case .GRIMCHILD:{
				models[.GRIMCHILD] = LoadModel("../data/hollow.glb")
			}
			case .WALL:{
				models[.WALL]      = LoadModel("../data/cube.glb")
			}
			case .GREY_WALL:{
				models[.GREY_WALL] = LoadModel("../data/grey_cube.glb")
			}
			case .SHRADDHA_KO_GHAR:{
				models[.SHRADDHA_KO_GHAR] = LoadModel("../data/shradd_house.glb")
			}
			case .STONE:{
				models[.STONE] = LoadModel("../data/rock.glb")
			}
		}
		*/
		//models[.GRASS]     = LoadModel("../data/Grass.glb")
		models[.PLAYER]    = LoadModel("../data/security_officer/untitled.glb")
		game_state.asset.player_animation = LoadModelAnimations("../data/hollow.glb", &game_state.asset.player_anim_count)
		//player_anim_frame_counter = 0
		game_state.asset.debug_builder = strings.builder_make(); 
		models[.WALL]      = LoadModel("../data/cube.glb")
		models[.GRIMCHILD] = LoadModel("../data/hollow.glb")
		models[.GREY_WALL] = LoadModel("../data/grey_cube.glb")

		models[.SHRADDHA_KO_GHAR] = LoadModel("../data/shradd_house.glb")
		models[.STONE] = LoadModel("../data/rock.glb")

		game_state.asset.debug_font = LoadFontEx("../data/Bitter-Medium.ttf", 300, nil, 256)

		//loaded += 1
		//if(loaded == len(models)){
			print("Loaded All Asset ")
			//initilize_game()
		//}
	}





