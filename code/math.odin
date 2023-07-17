package main

import "core:math"

v4     :: [4]f32
rec2   :: matrix[2,2]f32
//rec3   :: matrix[2,3]f32


v2_f32 :: [2]f32
v2_i32 :: [2]i32

v3_f32 :: vec3
v3_i32 :: [3]i32

rec3 :: struct{
	min : v3_f32,
	max : v3_f32,
}

square :: proc(a: f32)-> f32{
	res := a * a
	return res
}

inner :: proc(a: v3_f32, b: v3_f32)-> f32{
	res := a.x * b.x + a.y *b.y + a.z * b.z;
	return res;
}

length_sq :: proc(a: v3_f32)-> f32{
	res := inner(a, a);
	return res;
}

sq_root :: proc(f: f32)-> f32{
	res := math.sqrt_f32(f);
	return res
}

length :: proc(a: v3_f32)-> f32{
	res := sq_root(length_sq(a));
	return res;
}
