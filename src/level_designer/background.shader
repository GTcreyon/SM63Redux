shader_type canvas_item;

uniform vec2 camera_position = vec2(0, 0);

const float outline_thickness = 1f;
const float origin_thickness = 2f;
const float outline_spacing = 32f;

float modf_gles2(float x, float range) {
	return x - range * floor(x / range);
}

void fragment()
{
	//calculate if this pixel is an outline pixel
	//main outline
	bool is_outline =
		modf_gles2(UV.x + camera_position.x * TEXTURE_PIXEL_SIZE.x, TEXTURE_PIXEL_SIZE.x * outline_spacing)
			<= TEXTURE_PIXEL_SIZE.x * outline_thickness ||
		modf_gles2(UV.y + camera_position.y * TEXTURE_PIXEL_SIZE.y, TEXTURE_PIXEL_SIZE.y * outline_spacing)
			<= TEXTURE_PIXEL_SIZE.y * outline_thickness;
	
	//half outlines
	is_outline = is_outline ||
		modf_gles2(UV.y + camera_position.y * TEXTURE_PIXEL_SIZE.y, TEXTURE_PIXEL_SIZE.y * outline_spacing * 0.5f)
			<= TEXTURE_PIXEL_SIZE.y * outline_thickness &&
		modf_gles2(
				UV.x + camera_position.x * TEXTURE_PIXEL_SIZE.x + TEXTURE_PIXEL_SIZE.x * outline_spacing * 0.125f,
				TEXTURE_PIXEL_SIZE.x * outline_spacing * 0.5f
			)
			<= TEXTURE_PIXEL_SIZE.x * outline_spacing * 0.25f;
	is_outline = is_outline ||
		modf_gles2(UV.x + camera_position.x * TEXTURE_PIXEL_SIZE.x, TEXTURE_PIXEL_SIZE.x * outline_spacing * 0.5f)
			<= TEXTURE_PIXEL_SIZE.x * outline_thickness &&
		modf_gles2(
				UV.y + camera_position.y * TEXTURE_PIXEL_SIZE.y + TEXTURE_PIXEL_SIZE.y * outline_spacing * 0.125f,
				TEXTURE_PIXEL_SIZE.y * outline_spacing * 0.5f
			)
			<= TEXTURE_PIXEL_SIZE.y * outline_spacing * 0.25f;
	
	//origin outlines
	is_outline = is_outline ||
		UV.x + camera_position.x * TEXTURE_PIXEL_SIZE.x
			<= TEXTURE_PIXEL_SIZE.x * origin_thickness &&
		UV.x + camera_position.x * TEXTURE_PIXEL_SIZE.x
			>= -TEXTURE_PIXEL_SIZE.x * origin_thickness;
	is_outline = is_outline ||
		UV.y + camera_position.y * TEXTURE_PIXEL_SIZE.y
			<= TEXTURE_PIXEL_SIZE.y * origin_thickness &&
		UV.y + camera_position.y * TEXTURE_PIXEL_SIZE.y
			>= -TEXTURE_PIXEL_SIZE.y * origin_thickness;
	
	//we do 1 - y component of the SCREEN_UV because otherwise the image is flipped
	COLOR = is_outline ? vec4(0, 0, 0, 1) : texture(TEXTURE, vec2(SCREEN_UV.x, 1f - SCREEN_UV.y));
}
