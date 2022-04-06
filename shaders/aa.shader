shader_type canvas_item;

void fragment(){
	//vec4 back_col = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR = texture(TEXTURE, UV);
	if (COLOR == vec4(93./255., 85./255., 88./255., 1.))
	{
		COLOR = vec4(57./255., 24./255., 0., 0.5);
	}
}