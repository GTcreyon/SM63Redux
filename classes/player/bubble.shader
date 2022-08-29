shader_type canvas_item;

uniform vec4 base_color : hint_color = vec4(0.54, 0.70, 0.83, 0.63);
uniform vec4 outline_color : hint_color = vec4(0.47, 0.59, 0.81, 0.63);
uniform vec4 shine_color : hint_color = vec4(0.98, 0.91, 0.91, 0.63);
uniform sampler2D viewport_texture;

// OKAY SO
// transparent bg viewports are apparently messed up on OSX
// so until Godot is fixed, we'll be using the red channel instead of the alpha channel
void fragment() {
	vec4 col = texture(viewport_texture, UV);
	if (col.r == 0.) {
		COLOR = vec4(0);
	}
	else {
		col = base_color;
	
		float outline_sum = 0.;
		outline_sum += sign(texture(viewport_texture, UV + vec2(0, TEXTURE_PIXEL_SIZE.y)).r);
		outline_sum += sign(texture(viewport_texture, UV + vec2(0, TEXTURE_PIXEL_SIZE.y * 2.)).r);
		outline_sum += sign(texture(viewport_texture, UV - vec2(0, TEXTURE_PIXEL_SIZE.y)).r);
		outline_sum += sign(texture(viewport_texture, UV - vec2(0, TEXTURE_PIXEL_SIZE.y * 2.)).r);
		outline_sum += sign(texture(viewport_texture, UV + vec2(TEXTURE_PIXEL_SIZE.x, 0)).r);
		outline_sum += sign(texture(viewport_texture, UV + vec2(TEXTURE_PIXEL_SIZE.x * 2., 0)).r);
		outline_sum += sign(texture(viewport_texture, UV - vec2(TEXTURE_PIXEL_SIZE.x, 0)).r);
		outline_sum += sign(texture(viewport_texture, UV - vec2(TEXTURE_PIXEL_SIZE.x * 2., 0)).r);
		if (outline_sum != 8.) {
			col = outline_color;
		}
		
		COLOR = col;
	}
}
