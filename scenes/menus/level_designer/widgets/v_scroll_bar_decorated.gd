class_name VScrollBarDecorated
extends VScrollBar
## Scroll bar with a decoration icon at the center of the grabber.

@export var decoration: Texture2D

var deco_sprite: TextureRect
var deco_tex: Texture2D
var deco_tex_highlight: Texture2D
var deco_tex_pressed: Texture2D

func _ready():
	# Read decoration textures from theme
	# Create decoration node.
	deco_sprite = TextureRect.new()
	deco_sprite.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	deco_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Add it to the tree.
	add_child(deco_sprite, false, Node.INTERNAL_MODE_BACK)
	
	# Load decoration visuals from the theme.
	deco_tex = decoration
	#deco_tex = theme.get_icon("decoration", "VScrollBarDecorated")
	#deco_tex_highlight = theme.get_icon("decoration_highlight", "VScrollBarDecorated")
	#deco_tex_pressed = theme.get_icon("decoration_pressed", "VScrollBarDecorated")
	
	# Init sprite to showing one.
	deco_sprite.texture = deco_tex


#func _draw():
#	match 
