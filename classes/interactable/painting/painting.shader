shader_type canvas_item;

uniform float flash_factor = 0;
uniform vec2 ripple_origin = vec2(0.5, 0.5);
uniform float ripple_amplitude = 1.0;
uniform float ripple_phase = 0;
uniform float ripple_frequency = 1;

const float PI = 3.1415927;

void fragment() {
	// TODO: Pixel perfect UV. This would be the spot, before
	// any distances are calculated.
	vec2 ripple_dir = normalize(UV - ripple_origin); //Dir from origin to ripple
	float ripple_dist = distance(UV, ripple_origin); //Dist from origin to ripple

	// Get the actual shape of the ripple in the right spot.
	float ripple_shape = ripple_dist - ripple_phase;
	ripple_shape *= ripple_frequency;
	ripple_shape *= 2.0 * PI;
	// Convert it to a ripple. Double sine looks a bit shapier.
	ripple_shape = sin(sin(ripple_shape));

	// Take the direction to the ripple origin.
	vec2 ripple_effect = ripple_dir;
	// Multiply the ripple's actual shape into that.
	ripple_effect *= ripple_shape;
	// Scale the magnitude of the ripple displacement too, of course.
	ripple_effect *= ripple_amplitude;

	// Displace the UV map.
	vec2 ripple_uv = UV + ripple_effect;

	vec4 c = texture(TEXTURE, ripple_uv);
	c.rgb += vec3(flash_factor);
	COLOR = c;
}