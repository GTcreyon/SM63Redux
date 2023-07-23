shader_type canvas_item;

uniform vec2 texture_resolution = vec2(82,82);
uniform vec2 ripple_origin = vec2(0.5, 0.5);
uniform float ripple_amplitude = 0;
uniform float ripple_phase = 0;
uniform float ripple_frequency = 3;

uniform float flash_factor = 0;

uniform float burnaway_factor = 0;
uniform sampler2D burnaway_mask;
uniform float burnaway_mask_factor = 0.01;

// Float version of lhs <= rhs.
float leq (float lhs, float rhs) {
	return floor(lhs / rhs);
}

float remap (float value, float old_min, float old_max, float new_min, float new_max) {
	// Factor away min value.
	value -= old_min;
	// Un-fit it from the old range. Now it's 0-1.
	value /= old_max - old_min;

	// Squish it to the new range.
	value *= new_max - new_min;
	// Slide it to the new min.
	value += new_min;

	return value;
}

vec2 pixel_snap (vec2 vector) {
	return floor(vector * texture_resolution) / texture_resolution;
}

void fragment() {
	vec2 ripple_dir = normalize(pixel_snap(UV) - ripple_origin); //Dir from origin to ripple
	float ripple_dist = distance(pixel_snap(UV), ripple_origin); //Dist from origin to ripple

	// Get the actual shape of the ripple in the right spot.
	float ripple_shape = ripple_dist - ripple_phase;
	ripple_shape *= ripple_frequency;
	ripple_shape *= 2.0 * PI;
	// Convert it to a ripple. Double sine looks more 3D.
	ripple_shape = sin(sin(ripple_shape)*PI);
	

	// Take the direction to the ripple origin.
	vec2 ripple_effect = ripple_dir;
	// Multiply the ripple's actual shape into that.
	ripple_effect *= ripple_shape;
	// Scale the magnitude of the ripple displacement too, of course.
	ripple_effect *= ripple_amplitude;
	ripple_effect = pixel_snap(ripple_effect);

	// Displace the UV map.
	vec2 ripple_uv = UV + ripple_effect;

	vec4 c = texture(TEXTURE, ripple_uv);
	c.rgb += vec3(flash_factor);
	
	//Overwrite the alpha with the undisplaced value
	c.a = texture(TEXTURE, UV).a;
	
	// Burn ripples lower than a threshold away to white.
	float burnaway = (ripple_shape / 2. + 0.5);
	// Shift the threshold using a mask.
	float mask = texture(burnaway_mask, pixel_snap(ripple_uv)).r;
	mask *= 2.;
	mask -= 1.;
	mask *= burnaway_mask_factor;
	burnaway += mask;
	burnaway = remap(burnaway, 
		-burnaway_mask_factor, 1.0+burnaway_mask_factor, // Old range
		0.,1. ); // New range
	// Convert to a solid black-and-white mask.
	burnaway = leq(burnaway, burnaway_factor);
	// Invert the mask.
	burnaway = 1. - burnaway;
	// Rid of anything under 0.
	burnaway = clamp(burnaway, 0, 1);

	c.rgb += vec3(burnaway);
	//COLOR = vec4(vec3(ripple_shape),1);
	COLOR = c;
}