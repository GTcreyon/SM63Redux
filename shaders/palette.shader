shader_type canvas_item;

uniform vec4 color0 : hint_color;
uniform vec4 color1 : hint_color;
uniform vec4 color2 : hint_color;
uniform vec4 color3 : hint_color;
uniform vec4 color4 : hint_color;
uniform vec4 color5 : hint_color;

void fragment(){
	COLOR = texture(TEXTURE, UV);
	if (COLOR == vec4(1, 0, 0, 1)) //red
	{
		COLOR = color0;
	}
	else if (COLOR == vec4(0, 1, 0, 1)) //green
	{
		COLOR = color1;
	}
	else if (COLOR == vec4(0, 0, 1, 1)) //blue
	{
		COLOR = color2;
	}
	else if (COLOR == vec4(1, 1, 0, 1)) //yellow
	{
		COLOR = color3;
	}
	else if (COLOR == vec4(1, 0, 1, 1)) //magenta
	{
		COLOR = color4;
	}
	else if (COLOR == vec4(0, 1, 1, 1)) //cyan
	{
		COLOR = color5;
	}
}