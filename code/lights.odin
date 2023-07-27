package main

import rl "vendor:raylib"
import "core:strings"
import "core:fmt"

LightType :: enum {
	DIRECTIONAL,
	POINT,
}

Light :: struct {
	type   : LightType,
	pos    : vec3,
	target : vec3,
	color  : rl.Color,
	enabled: bool, 

	//shader locations
	enabled_loc: i32,
	type_loc   : i32,
	pos_loc    : i32,
	target_loc : i32,
	color_loc  : i32,
}


MAX_LIGHTS :: 4

//put this in platform state
lightsCount : int = 0

create_light :: proc(type: LightType, position: vec3, target: vec3,  color: rl.Color, shader: rl.Shader) -> Light{
	light : Light = {}

	using strings
	

	if(lightsCount < MAX_LIGHTS){
		light.enabled = true
		light.type    = type
		light.pos     = position
		light.target  = target
		light.color   = color

		light.enabled_loc = rl.GetShaderLocation(shader, unsafe_string_to_cstring(fmt.aprintf("lights[%d].enabled", lightsCount)))
		light.type_loc    = rl.GetShaderLocation(shader, unsafe_string_to_cstring(fmt.aprintf("lights[%d].type",    lightsCount)))
		light.pos_loc     = rl.GetShaderLocation(shader, unsafe_string_to_cstring(fmt.aprintf("lights[%d].position",lightsCount)))
		light.target_loc  = rl.GetShaderLocation(shader, unsafe_string_to_cstring(fmt.aprintf("lights[%d].target",  lightsCount)))
		light.color_loc   = rl.GetShaderLocation(shader, unsafe_string_to_cstring(fmt.aprintf("lights[%d].color",   lightsCount)))

		update_light_values(shader, &light)

		lightsCount += 1;
	}
	return light
}


//Send light properties to to shader
//NOTE : light shader locations should be available


update_light_values :: proc(shader: rl.Shader, light: ^Light){
	using rl;


	SetShaderValue(shader, auto_cast(light.enabled_loc), &light.enabled, .INT)
	SetShaderValue(shader, auto_cast(light.type_loc), &light.type, .INT)

	SetShaderValue(shader, auto_cast(light.pos_loc), &light.pos[0], .VEC3)
	SetShaderValue(shader, auto_cast(light.target_loc), &light.target[0], .VEC3)

	color := vec4{f32(light.color.r) / 255.0, f32(light.color.g) /255, f32(light.color.b)/255.0, f32(light.color.a) /255 }
	SetShaderValue(shader, auto_cast(light.color_loc), &color[0], .VEC4)
}
