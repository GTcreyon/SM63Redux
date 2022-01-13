shader_type canvas_item;

uniform vec4 outline_color : hint_color = vec4(0.2, 0.7, 1, 0.8);
uniform vec4 base_water_color : hint_color = vec4(0.2, 0.7, 1, 0.8);
uniform float outline_size = 6f;
uniform float second_size = 2f;
uniform sampler2D viewport_texture;
uniform sampler2D outline_texture;

uniform vec2 outline_texture_size;
uniform float outline_anim_phase = 0;

float modf_gles2(float x, float range) {
	return x - range * floor(x / range);
}

void fragment() {
	vec4 col = texture(viewport_texture, UV);
	if (col.a == 0f) { return; }
	col.a = base_water_color.a;
	
	float outline_sum = 0f;
	for (float inc = 1f; inc <= outline_size; inc++) {
		outline_sum += sign(texture(viewport_texture, UV - vec2(0, TEXTURE_PIXEL_SIZE.y * inc)).a);
	}
	if (outline_sum != outline_size) {
		float px_y = outline_sum / outline_size * outline_texture_size.y
			+ outline_anim_phase * outline_texture_size.y;
		col = texture(outline_texture, vec2(
			modf_gles2(
				UV.x * (1f / TEXTURE_PIXEL_SIZE.x) / outline_texture_size.x,
				1f
			),
			px_y / 24f
		));
		//col = texture(outline_texture, vec2(0.5f, 0.2f));
	}
	//reset the data and do the same for a second outline
	outline_sum = 0f;
	for (float inc = outline_size + 1f; inc <= outline_size + second_size; inc++) {
		outline_sum += sign(texture(viewport_texture, UV - vec2(0, TEXTURE_PIXEL_SIZE.y * inc)).a);
	}
	if (outline_sum != second_size) {
		col *= 0.5f;
		col += outline_color * 0.5;
	}
	
	COLOR = col;
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