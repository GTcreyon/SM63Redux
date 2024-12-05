// made by RandomCatDude for revamped fludd particle fx
shader_type canvas_item;

uniform ivec2 frame_count = ivec2(2, 2);
uniform float expand_reduce: hint_range(-1, 1) = 0.01;

void vertex() {
	vec2 frames = vec2(frame_count);
	float frames_total = frames.x * frames.y;

	// By default, the particle will size itself to the entire texture.
	// Downsize vertices and UVs to fit the size of one frame instead.
	VERTEX.xy /= frames;
	UV /= frames;

	// Pick a random frame for this particle.
	// (INSTANCE_CUSTOM.z is a random seed.)
	float chosen_frame = floor(INSTANCE_CUSTOM.z * frames_total);
	chosen_frame = mod(chosen_frame, frames_total);
	// Place the UVs on that frame.
	UV += vec2(
		mod(chosen_frame, frames.x) / frames.x, // Extract column
		floor((chosen_frame + 0.5) / frames.x) / frames.y // Extract row
	);
}

void fragment()
{
	// Take the default alpha (vertex color times texture).
	float new_alpha = COLOR.a;
	// Expand/reduce the alpha.
	new_alpha *= 1.0 + expand_reduce;
	// Add the raw texture onto it. This bypasses vertex colors, meaning
	// adding it pushes everything we care about above 1.
	// (We can't just add a flat 1 to everything--that'd make everything
	// pass the floor test we do later!)
	new_alpha += texture(TEXTURE, UV).a;
	// Finally, cut off the fraction. Anything above 1 will be kept.
	COLOR.a = floor(new_alpha);
}