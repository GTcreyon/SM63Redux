shader_type canvas_item;

uniform vec4 base_water_color : source_color = vec4(0.2, 0.7, 1, 0.8);
uniform sampler2D viewport_texture;
uniform sampler2D outline_texture;

uniform vec2 outline_texture_size;
uniform float outline_anim_phase = 0;

const vec2 ATLAS_SIZE = vec2(32, 48);
const vec4 COL_BLACK = vec4(0, 0, 0, 1);
const vec4 COL_BROWN = vec4(0.224, 0.094, 0, 1);
const float ANIM_STABLE_OFFSET = 0.1 / ATLAS_SIZE.y;

float modf_gles2(float x, float range) {
	return x - range * floor(x / range);
}

void fragment() {
	vec4 col = texture(viewport_texture, UV);
	if (col.r == 0.) {
		COLOR = vec4(0);
	}
	else {
		col.a = base_water_color.a;
		
		float outline_sum = 0.;
		for (float inc = 1.; inc <= outline_texture_size.y; inc++) {
			outline_sum += sign(texture(viewport_texture, UV - vec2(0, TEXTURE_PIXEL_SIZE.y * inc)).r);
		}
		
		float should_be_brown = sign(texture(viewport_texture, UV - vec2(0, TEXTURE_PIXEL_SIZE.y)).r) +
			sign(texture(viewport_texture, UV + vec2(0, TEXTURE_PIXEL_SIZE.y)).r) +
			sign(texture(viewport_texture, UV - vec2(TEXTURE_PIXEL_SIZE.x, 0)).r) +
			sign(texture(viewport_texture, UV + vec2(TEXTURE_PIXEL_SIZE.x, 0)).r);
		
		if (outline_sum != outline_texture_size.y) {
			vec2 px = vec2(
				modf_gles2(
					UV.x * (1. / TEXTURE_PIXEL_SIZE.x) / outline_texture_size.x,
					1.
				),
				(outline_sum + outline_anim_phase / 4.) / ATLAS_SIZE.y + ANIM_STABLE_OFFSET
			);
			vec4 text_col = texture(outline_texture, px);
			col = text_col == COL_BLACK ? col : text_col;
			if (col.a != 0. && should_be_brown != 4.) {
				col = COL_BROWN;
			}
		} else if (should_be_brown != 4.) {
			col = COL_BROWN;
		}
		
		COLOR = col;
	}
}

/*
uniform sampler2D viewport_texture;

void fragment() {
	vec4 color = texture(viewport_texture, UV);
	if (color.a == 0f) {return;}
	COLOR = color;
	//COLOR = vec4(UV.x, 0, 0, 0.5);
}
*/