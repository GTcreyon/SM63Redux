shader_type canvas_item;

uniform float flash_factor = 0;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	c.rgb += vec3(flash_factor);
	COLOR = c;
}