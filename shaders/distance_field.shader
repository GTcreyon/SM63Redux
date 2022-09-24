// made by RandomCatDude for revamped fludd particle fx
shader_type canvas_item;

uniform int particles_anim_h_frames;
uniform int particles_anim_v_frames;

void vertex() {
	float h_frames = float(particles_anim_h_frames);
	float v_frames = float(particles_anim_v_frames);
	VERTEX.xy /= vec2(h_frames, v_frames);
	float particle_total_frames = float(particles_anim_h_frames * particles_anim_v_frames);
	float particle_frame = floor(INSTANCE_CUSTOM.z * float(particle_total_frames));
	
	particle_frame = mod(particle_frame, particle_total_frames);
	
	UV /= vec2(h_frames, v_frames);
	UV += vec2(mod(particle_frame, h_frames) / h_frames, floor((particle_frame + 0.5) / h_frames) / v_frames);
}

void fragment()
{
	COLOR.a = floor(texture(TEXTURE, UV).a + COLOR.a - 0.01);
}