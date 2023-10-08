//adapted heavily from https://github.com/steincodes/godot-shader-tutorials/blob/master/Shaders/outline.shader
shader_type canvas_item;
render_mode unshaded;

uniform int width : hint_range(0, 32) = 1;
uniform bool radial;
uniform vec4 outline_color : source_color = vec4(1);

void vertex()
{
	// Expand the polygon bounds to make space for the outline to show.
	
	// Multiply the width by the sign of this vert's position.
	// Sign of vert is a quick, cheap way to get a "move each edge one pixel
	// outward" vector, assuming the mesh is a simple quad and the origin is
	// the exact center.
	// This is true in most cases currently attested in the game, except for
	// Shine Sprites.
	vec2 expand_vertex = vec2(float(width)) * sign(VERTEX);
	// Contract the UVs to compensate for the expanded vertex bounds.
	UV += (expand_vertex / VERTEX) * UV;
	// Shift it back to center by one pixel.
	UV -= float(width) * TEXTURE_PIXEL_SIZE;
	
	VERTEX += expand_vertex;
}

void fragment() 
{	
	COLOR = texture(TEXTURE, UV);
	if(COLOR.a <= 0. || UV.x > 1. || UV.x < 0. || UV.y > 1. || UV.y < 0.){
		for(float x = -float(width); x <= float(width); x += 1.){ //idk why this needs to be a float AWNSER: because you can't do int + float, and x is a float
			for(float y = -float(width); y <= float(width); y += 1.){
				//exclude pixels outside the mask
				if(distance(vec2(0), vec2(float(x), float(y))) > float(width) && radial || abs(x) == abs(y) && !radial)
					continue;

				vec2 neighbor_uv = UV + vec2(TEXTURE_PIXEL_SIZE.x * float(x), TEXTURE_PIXEL_SIZE.y * float(y)); 

				//fail when OoB
				vec4 neighbor_col = texture(TEXTURE, neighbor_uv);
				if((neighbor_uv.x < 0. || neighbor_uv.x > 1.) || (neighbor_uv.y < 0. || neighbor_uv.y > 1.)){
					neighbor_col = vec4(0);
				}

				if(neighbor_col.a > 0.){
					COLOR = outline_color;
				}
			}
		}
	}
	
	// DEBUG: Highlight spots outside the texture.
	//COLOR.rg = sign(abs(UV - clamp(UV, 0.0, 1.0)));
	//COLOR.ba = vec2(0.0, 1.0);
}