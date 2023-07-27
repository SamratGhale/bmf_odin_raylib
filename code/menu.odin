package main

import rl "vendor:raylib"
import "core:reflect"
import "core:strings"

MenuOptions :: enum {
	RESUME, 
	SOUND, 
	GAMEPAD,
	EXIT,
}

MenuState :: struct {
	selected_option  : MenuOptions,
	initilized : bool,
	space_texture : rl.Texture,
	shader : rl.Shader,
	seconds : f32,
	secondsLoc: i32,
	debug_font : rl.Font,
}

draw_menu :: proc (){

	menu_state := cast(^MenuState)(platform.arena.curr_block.base)

	using menu_state;
	using strings
	using rl
	//load_all_asset()

	if !initilized{

		//initilize_game()


		debug_font = LoadFontEx("../data/Bitter-Medium.ttf", 300, nil, 256)
		space_texture = LoadTexture("../data/space.png")
		shader = LoadShader(nil, "../code/wave_frag.glsl")

		texLoc := GetShaderLocation(shader, "texture0")
		secondsLoc = GetShaderLocation(shader, "secondes")
		freqXLoc := GetShaderLocation(shader, "freqX")
		freqYLoc := GetShaderLocation(shader, "freqY")
		ampXLoc := GetShaderLocation(shader, "ampX")
		ampYLoc := GetShaderLocation(shader, "ampY")
		speedXLoc := GetShaderLocation(shader, "speedX")
		speedYLoc := GetShaderLocation(shader, "speedY")

	    // Shader uniform values that can be updated at any time
	    freqX  :f32= 25.0
	    freqY  :f32= 25.0
	    ampX   :f32= 5.0
	    ampY   :f32= 5.0
	    speedX :f32= 8.0
	    speedY :f32= 8.0

	    screenSize: [2]f32 = { cast(f32)screen_width, cast(f32)screen_height };

	    //SetShaderValueTexture(shader, auto_cast(texLoc), space_texture)

	    SetShaderValue(shader, auto_cast(GetShaderLocation(shader, "size")), &screenSize[0], .VEC2);

	    SetShaderValue(shader, auto_cast(freqXLoc), &freqX, .FLOAT);
	    SetShaderValue(shader, auto_cast(freqYLoc), &freqY, .FLOAT);
	    SetShaderValue(shader, auto_cast(ampXLoc), &ampX, .FLOAT); 
	    SetShaderValue(shader, auto_cast(ampYLoc), &ampY, .FLOAT);
	    SetShaderValue(shader, auto_cast(speedXLoc), &speedX, .FLOAT);
	    SetShaderValue(shader, auto_cast(speedYLoc), &speedY, .FLOAT);

	    seconds = 0

	    initilized = true
	}

	seconds += GetFrameTime()
	SetShaderValue(shader, auto_cast(secondsLoc), &seconds, .FLOAT);


	BeginDrawing()
	ClearBackground(RAYWHITE)
	BeginShaderMode(shader)


	//DrawTexture(space_texture, 0,0, WHITE)
	DrawTexturePro(
		space_texture,
		Rectangle{ 0, 0, f32(space_texture.width), f32(space_texture.height) },
		Rectangle{ 0, 0, f32(GetScreenWidth()), f32(GetScreenHeight()) },
		{ 0, 0 },
		0,
		WHITE);
	//DrawTexture(space_texture, space_texture.width,0, WHITE)
	//DrawTexture(space_texture, 0,space_texture.height, WHITE)
	//DrawTexture(space_texture, space_texture.width,space_texture.height, WHITE)
	EndShaderMode()

	start :i32= 100
	for val in MenuOptions{
		text := unsafe_string_to_cstring(reflect.enum_string(val))
		tex_len := MeasureText(text, 100)

		if(val == selected_option){
			DrawRectangleGradientH(100, start , tex_len, 100, GREEN, BLUE)
		}
		DrawTextEx(debug_font, text, {100, f32(start)}, 100, 0, WHITE)
		start += 100
	}

	EndDrawing()

	if(IsKeyPressed(.DOWN)){
		if(int(selected_option) + 1) < len(MenuOptions){
			selected_option = MenuOptions(int(selected_option) + 1)
		}
	}
	if(IsKeyPressed(.UP)){
		if(int(selected_option) - 1) >= 0{
			selected_option = MenuOptions(int(selected_option) - 1)
		}
	}

	if(IsKeyPressed(.ESCAPE)){
		platform.running = false
	}
	if(IsKeyPressed(.ENTER)){
		switch(selected_option){
			case .EXIT:{
				platform.running = false
			}
			case .RESUME:{
				platform.game_mode = .GAME_MODE_PLAY;
			}
			case .SOUND:{

			}
			case .GAMEPAD:{

			}
		}
	}
}












