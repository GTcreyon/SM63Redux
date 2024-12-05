shader_type canvas_item;

uniform sampler2D check_texture;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;

const vec4 ignore_px = vec4(1.0, 0.0, 188.0 / 255.0, 1.0);

void fragment()
{
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	if (screen_color.a == 1.) {
		COLOR = texture(TEXTURE, UV);
	} else {
		COLOR = vec4(0., 0., 0., 1.);
	}
//	vec4 color = texture(TEXTURE, UV);
//	if (color == ignore_px) {
//		vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
//		if (screen_color.r >= 0.8) {
//			COLOR = vec4(0.7, 0.2, 0, 1);
//		} else {
//			COLOR = vec4(0, 0, 0, 0);
//		}
//	} else {
//		COLOR = color;
//	}
}
