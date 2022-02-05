shader_type canvas_item;

void fragment(){
	//vec4 back_col = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR = texture(TEXTURE, UV);
	if (COLOR == vec4(93f/255f, 85f/255f, 88f/255f, 1f))
	{
		COLOR = vec4(57f/255f, 24f/255f, 0f, 0.5f))
	}