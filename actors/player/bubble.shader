shader_type canvas_item;

uniform vec4 base_color : hint_color = vec4(0.54, 0.70, 0.83, 0.63);
uniform vec4 outline_color : hint_color = vec4(0.47, 0.59, 0.81, 0.63);
uniform vec4 shine_color : hint_color = vec4(0.98, 0.91, 0.91, 0.63);
uniform sampler2D viewport_texture;

void fragment() {
	vec4 col = texture(viewport_texture, UV);
	if (col.a == 0f) {return;}
	col = base_color;
	
	float outline_sum = 0f;
	outline_sum += sign(texture(viewport_texture, UV + vec2(0, TEXTURE_PIXEL_SIZE.y)).a);
	outline_sum += sign(texture(viewport_texture, UV + vec2(0, TEXTURE_PIXEL_SIZE.y * 2f)).a);
	outline_sum += sign(texture(viewport_texture, UV - vec2(0, TEXTURE_PIXEL_SIZE.y)).a);
	outline_sum += sign(texture(viewport_texture, UV - vec2(0, TEXTURE_PIXEL_SIZE.y * 2f)).a);
	outline_sum += sign(texture(viewport_texture, UV + vec2(TEXTURE_PIXEL_SIZE.x, 0)).a);
	outline_sum += sign(texture(viewport_texture, UV + vec2(TEXTURE_PIXEL_SIZE.x * 2f, 0)).a);
	outline_sum += sign(texture(viewport_texture, UV - vec2(TEXTURE_PIXEL_SIZE.x, 0)).a);
	outline_sum += sign(texture(viewport_texture, UV - vec2(TEXTURE_PIXEL_SIZE.x * 2f, 0)).a);
	if (outline_sum != 8f) {col = outline_color;}
	
	COLOR = col;
}
