//adapted heavily from https://github.com/steincodes/godot-shader-tutorials/blob/master/Shaders/outline.shader
shader_type canvas_item;
render_mode unshaded;

uniform float width = 1.;
uniform bool recenter;
uniform bool radial;
uniform vec4 outline_color : hint_color = vec4(1);

varying vec2 extra_movement;

void vertex()
{
	// increase the size by the the width, this extra space is needed for the outline
	extra_movement = TEXTURE_PIXEL_SIZE * width * 2.;
	VERTEX *= 1. + extra_movement;
	if (recenter)
	{
		VERTEX -= vec2(1, 1) * width;
	}
}

void fragment(){
	//using capitals here since this is read only
	vec2 REALUV = UV;
	// yes it's important to FIRST recenter, THEN inverse the size increase
	// otherwise the texture will shrink a bit
	// recenter
	REALUV -= extra_movement * .5 - TEXTURE_PIXEL_SIZE * .25;
	// inverse the vertex size increase
	REALUV /= 1. - extra_movement + TEXTURE_PIXEL_SIZE * .5;
	
	COLOR = texture(TEXTURE, REALUV);
	if(COLOR.a <= 0. || REALUV.x > 1. || REALUV.x < 0. || REALUV.y > 1. || REALUV.y < 0.){
		for(float x = -float(width); x <= float(width); x += 1.){ //idk why this needs to be a float AWNSER: because you can't do int + float, and x is a float
			for(float y = -float(width); y <= float(width); y += 1.){
				//exclude pixels outside the mask
				if(distance(vec2(0), vec2(float(x), float(y))) > float(width) && radial || abs(x) == abs(y) && !radial)
					continue;

				vec2 neighbor_uv = REALUV + vec2(TEXTURE_PIXEL_SIZE.x * float(x), TEXTURE_PIXEL_SIZE.y * float(y)); 

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
}