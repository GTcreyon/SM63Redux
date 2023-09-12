// made by RandomCatDude for revamped fludd particle fx
shader_type canvas_item;

uniform ivec2 frame_count = ivec2(2, 2);
uniform float cutoff_threshold: hint_range(0, 1) = 0.01;

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
	// Cut it off by a threshold. Above is white; below is black.
	COLOR.a = floor(texture(TEXTURE, UV).a + COLOR.a - cutoff_threshold);
}