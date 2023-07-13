shader_type canvas_item;

uniform vec4 base_water_color : source_color = vec4(0.2, 0.7, 1, 0.8);
uniform sampler2D surface_texture;

uniform vec2 surface_texture_size;
uniform float surface_anim_phase = 0;

const vec2 ATLAS_SIZE = vec2(32, 48);
const vec4 COL_BLACK = vec4(0, 0, 0, 1);
const vec4 COL_OUTLINE = vec4(0.224, 0.094, 0, 1);
const float ANIM_STABLE_OFFSET = 0.1 / ATLAS_SIZE.y;

float modf_gles2(float x, float range) {
	return x - range * floor(x / range);
}

void fragment() {
	// To begin with, texture color comes from the object's color tint factor
	// and UV is basically directly analog to fragment position.
	
	// Mask away bits of water that are outside the display polygon.
	vec4 col = texture(TEXTURE, UV);
	if (col.r == 0.0) {
		COLOR = vec4(0);
	}
	// Fill in water that's inside the polygon.
	else {
		// Load the base color for now.
		col.a = base_water_color.a;
		
		// Count pixels up from here to the surface.
		// If we're below the surface band, the sum will come out to be
		// exactly surface_texture_size.y.
		float surface_sum = 0.0;
		for (float inc = 1.0; inc <= surface_texture_size.y; inc++) {
			surface_sum += sign(texture(TEXTURE, UV - vec2(0, TEXTURE_PIXEL_SIZE.y * inc)).r);
		}
		
		// Detect all four edges
		float outline = 
			sign(texture(TEXTURE, UV - vec2(0, TEXTURE_PIXEL_SIZE.y)).r) + //Detect top pixels
			sign(texture(TEXTURE, UV + vec2(0, TEXTURE_PIXEL_SIZE.y)).r) + //bottom pixels
			sign(texture(TEXTURE, UV - vec2(TEXTURE_PIXEL_SIZE.x, 0)).r) + //left pixels
			sign(texture(TEXTURE, UV + vec2(TEXTURE_PIXEL_SIZE.x, 0)).r) //right pixels
			;
		
		// If we're in the surface band, render the surface texture.
		if (surface_sum != surface_texture_size.y) {
			// Sample the correct frame of the surface texture.
			vec2 px = vec2(
				modf_gles2(
					UV.x * (1.0 / TEXTURE_PIXEL_SIZE.x) / surface_texture_size.x,
					1.0
				),
				(surface_sum + surface_anim_phase / 4.0) / ATLAS_SIZE.y + ANIM_STABLE_OFFSET
			);
			vec4 tex_col = texture(surface_texture, px);
			// Overwrite black pixels with the water color.
			// TODO: Broken in 4.1.
			col = tex_col == COL_BLACK ? col : tex_col;
			
			// Render outline only on opaque pixels of the surface.
			if (col.a != 0.0 && outline != 4.0) {
				col = COL_OUTLINE;
			}
		}
		// Outside the surface band, render outline anywhere an edge is detected.
		else if (outline != 4.0) {
			col = COL_OUTLINE;
		}
		
		// Haven't hit surface band or the outline. Render water color.
		COLOR = col;
	}
	//COLOR = vec4(UV, 0, 1);
}

/*
void fragment() {
	vec4 color = texture(TEXTURE, UV);
	if (color.a == 0f) {return;}
	COLOR = color;
	//COLOR = vec4(UV.x, 0, 0, 0.5);
}
*/