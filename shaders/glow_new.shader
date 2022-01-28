shader_type canvas_item;

uniform vec2 atlas_dimensions = vec2(1);
uniform int width = 1;
uniform bool radial;
uniform vec4 outline_color : hint_color;

void fragment(){
	//using capitals here since this is read only
	vec2 REALUV = vec2(mod(atlas_dimensions.x * UV.x, 1), mod(atlas_dimensions.y * UV.y, 1));
	
	COLOR = texture(TEXTURE, REALUV);
	if(COLOR.a <= 0f){
		for(float x = -float(width); x <= float(width); x += 1f){ //idk why this needs to be a float
			for(float y = -float(width); y <= float(width); y += 1f){
				//exclude pixels outside the mask
				if(distance(vec2(0), vec2(float(x), float(y))) > float(width) && radial || abs(x) == abs(y) && !radial)
					continue;
					
				vec2 neighbor_uv = REALUV + vec2(TEXTURE_PIXEL_SIZE.x * float(x), TEXTURE_PIXEL_SIZE.y * float(y)); 
				
				//fail when OoB
				vec4 neighbor_col = texture(TEXTURE, neighbor_uv);
				if((neighbor_uv.x < 0f || neighbor_uv.x > 1f) || (neighbor_uv.y < 0f || neighbor_uv.y > 1f)){
					neighbor_col = vec4(0);
				}
				
				if(neighbor_col.a > 0f){
					COLOR = outline_color;
				}
			}
		}
	}
}