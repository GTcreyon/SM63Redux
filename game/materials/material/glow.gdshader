//adapted heavily from https://github.com/steincodes/godot-shader-tutorials/blob/master/Shaders/outline.shader
shader_type canvas_item;
render_mode unshaded;

const float EPSILON = 0.000001;

uniform int width : hint_range(0, 32) = 1;
uniform bool radial;
uniform vec4 outline_color : source_color = vec4(1);
// Number of cels in this object's spritesheet, across and down.
// Assumes a grid arrangement.
uniform vec2 cel_count = vec2(1,1);
// Vertex offset from center, in pixels.
// Should always equal the sprite's Offset value,
// plus half the sprite's size if not Centered.
uniform vec2 sprite_offset = vec2(0,0);

varying vec2 cel_index;

void vertex()
{
	// Expand the polygon bounds to make space for the outline to show.

	// Temporarily remove all offset from the sprite mesh.
	// The following calculations identify vertices and derive mesh size
	// based on vertex position, so offset vertices will throw everything off.
	vec2 vert_centered = VERTEX - sprite_offset;

	// Multiply the width by the sign of this vert's position.
	// Sign of vert is a quick, cheap way to get a "move each edge one pixel
	// outward" vector, assuming the mesh is a simple quad (in Godot, a sprite
	// always is) and the origin is the exact center (ensured by vert_centered).
	vec2 expand_vertex = vec2(float(width)) * sign(vert_centered);
	vec2 expand_factor = vert_centered / (vert_centered + expand_vertex);

	// Figure out which cel of the spritesheet we're currently in.
	cel_index = vec2(UV * cel_count) - vec2(1);
	// Outer edge thinks it's in the next cel over by position.
	// Account for that.
	cel_index -= min(sign(vert_centered), vec2(0));

	// Contract the UVs to compensate for the expanded vertex bounds.
	UV /= expand_factor;
	// Shift it back to center by two pixels per cel traveled from top-left,
	// plus one.
	UV -= float(width) * TEXTURE_PIXEL_SIZE * (2.0 * cel_index + vec2(1));

	VERTEX += expand_vertex;
}


bool uv_outside_cel(vec2 uv) {
	// Project the UV coordinates from cel space to texture space.
	vec2 uv_scaled = (uv * cel_count) - cel_index;
	// Detect the spots outside the texture.
	// Clamping only changes values outside the wanted area--
	// so detecting change means detecting those values.
	return clamp(uv_scaled, EPSILON, 1.0-EPSILON) != uv_scaled;
}


void fragment()
{
	COLOR = texture(TEXTURE, UV);

	// Trim away pixels outside the current cel, lest we draw pixels from
	// neighboring cels in the expanded margins.
	if (uv_outside_cel(UV)) {
		COLOR = vec4(0);
	}

	if(COLOR.a <= 0.0) {
		float widthf = float(width); // Not to be confused with fwidth!

		for (float x = -widthf; x <= widthf; x += 1.0) {
			for (float y = -widthf; y <= widthf; y += 1.0) {
				// Skip outlining pixels outside the detection area.
				// This rounds the corners--aggressively in radial mode,
				// gently otherwise.
				if (
					radial && distance(vec2(0), vec2(x, y)) > widthf ||
					!radial && abs(x) == abs(y)
				)
					continue;

				// Sample the texture (x, y) pixels over.
				vec2 neighbor_uv = UV + TEXTURE_PIXEL_SIZE * vec2(x, y);
				vec4 neighbor_col = texture(TEXTURE, neighbor_uv);

				// Draw the outline if there's anything at all visible there.
				// Pixels outside the UV area fail automatically, lest we
				// accidentally outline bits of neighboring cels.
				if (!uv_outside_cel(neighbor_uv) && neighbor_col.a > 0.0) {
					COLOR = outline_color;
				}
			}
		}
	}

	// DEBUG: Highlight spots outside the texture.
	//COLOR.rg = uv_outside_cel(UV)? vec2(1.0, 1.0) : vec2(0.0, 0.0);
	//COLOR.ba = vec2(0.0, 1.0);
}