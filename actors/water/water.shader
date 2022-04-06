shader_type canvas_item;

uniform vec4 base_water_color;
uniform vec2 water_xy_ratio;
uniform float texture_repeat;
uniform float normal_map_mult = 0.2;
uniform float animation_swing_range_px = 32.;
uniform float animation_speed = 1.;

const float PI = 3.14159265359;
const float TAU = 2. * PI;
const vec2 unit_vec = vec2(1, 1);

vec2 keep_bounds(vec2 vec) {return mod(vec, unit_vec);}

void fragment() {
	//uv setup
	vec2 real_uv = UV * water_xy_ratio;
	real_uv *= texture_repeat;
	//make sure we get a number range between 0-1
	real_uv = keep_bounds(real_uv);
	
	//handle normal map texture
	//move the uv for animation
	float animation_swing = animation_swing_range_px * SCREEN_PIXEL_SIZE.x;
	vec2 moved_uv = real_uv + vec2(cos(real_uv.y * TAU + TIME * animation_speed) * animation_swing, 0);
	moved_uv = keep_bounds(moved_uv);
	//get the pixel color of the texture
	/*
	float normal_map = texture(water_texture, moved_uv).a * normal_map_mult;
	COLOR = base_water_color + vec4(normal_map, normal_map, normal_map, 0);
	*/
	COLOR = base_water_color;
	COLOR.a = 1.;
}
