@tool
class_name VScrollBarDecorated
extends VScrollBar
## Scroll bar with a decoration icon at the center of the grabber.
##
## Please be warned that for technical reasons, the decoration's position can
## only be consistently correct if the scrollbar theme graphics have consistent
## size and padding across regular, focused, highlighted, and pressed states.

var deco_sprite: TextureRect
var block_top: TextureRect
var block_bottom: TextureRect

# Graphics, loaded from theme.
var deco_tex: Texture2D
var deco_tex_highlight: Texture2D
var deco_tex_pressed: Texture2D
var blocker_tex: Texture2D

# Sizes of textures surrounding the grabber. Need these to get the actual
# displayed bar height.
var _inc_height := 0.0
var _dec_height := 0.0
var _grabber_pad := 0.0

func _ready():
	# Read decoration textures from theme
	var theme_variation = theme_variation_or("VScrollBarDecorated")
	deco_tex = get_theme_icon("decoration", theme_variation)
	deco_tex_highlight = get_theme_icon("decoration_highlight", theme_variation)
	deco_tex_pressed = get_theme_icon("decoration_pressed", theme_variation)
	blocker_tex = get_theme_icon(&"blocker", theme_variation) if has_theme_icon(
		&"blocker", theme_variation) else null

	# Read heights of the surrounding textures.
	_inc_height = height_if_some(
		get_theme_icon("increment", theme_variation_or("VScrollBar"))
		)
	_dec_height = height_if_some(
		get_theme_icon("decrement", theme_variation_or("VScrollBar"))
		)
	_grabber_pad = _v_margins(
		get_theme_stylebox("grabber", theme_variation_or("VScrollBar"))
		)
	
	# Create decoration node.
	deco_sprite = TextureRect.new()
	deco_sprite.stretch_mode = TextureRect.STRETCH_KEEP
	deco_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Init sprite to non-interacted texture.
	deco_sprite.texture = deco_tex
	# Add it to the tree.
	add_child(deco_sprite, false, Node.INTERNAL_MODE_BACK)
	
	if blocker_tex:
		# Create blocker nodes. Unlike the buttons, these can overlap the grabber.
		block_top = TextureRect.new()
		block_top.stretch_mode = TextureRect.STRETCH_KEEP
		block_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
		block_top.texture = blocker_tex
		# Blocker should be a fixed size.
		block_top.custom_minimum_size = blocker_tex.get_size()
		# Both blockers are the same, just one's flipped.
		block_bottom = block_top.duplicate()
		block_bottom.flip_v = true
		# Add them to the tree.
		add_child(block_top, false, Node.INTERNAL_MODE_BACK)
		add_child(block_bottom, false, Node.INTERNAL_MODE_BACK)
		# Put them where they belong.
		_update_blocker_pos()


func _draw():
	var cur_sprite: Texture2D = deco_tex # TODO: Select by mouse-over state?
	# Abort if no texture.
	if cur_sprite == null:
		return
	
	# Calculate height of actual background area (without inc+dec buttons or
	# the inflexible parts of the grabber).
	var bar_height = size.y
	bar_height -= _inc_height
	bar_height -= _dec_height
	bar_height -= _grabber_pad
	
	# How much the bar is stretched relative to its value range.
	var bar_stretch = bar_height / (max_value - min_value)
	
	var grabber_height = page * bar_stretch
	
	var grabber_pos = (self.value - min_value) * bar_stretch
	grabber_pos += _dec_height
	
	deco_sprite.position = Vector2(0, 
		grabber_pos - cur_sprite.get_height()/2.0 + grabber_height/2.0)
	deco_sprite.size.y = cur_sprite.get_height()


func _notification(what):
	if what == NOTIFICATION_RESIZED and is_node_ready():
		# Update blocker positions.
		_update_blocker_pos()


func _update_blocker_pos():
	if blocker_tex:
		# Place the blockers right on the edges of the inc/dec buttons,
		# halfway above and halfway below.
		block_top.position = Vector2(0, _inc_height - blocker_tex.get_height() / 2)
		block_bottom.position = Vector2(0, (size.y - _dec_height) - blocker_tex.get_height() / 2)


## Returns [member Control.theme_type_variation] if it isn't [code]&""[/code], or the given [param default]
## if it is.
func theme_variation_or(default: StringName) -> StringName:
	if theme_type_variation == &"":
		return default
	else:
		return theme_type_variation


func _v_margins(stylebox: StyleBoxTexture) -> float:
	return stylebox.texture_margin_bottom + stylebox.texture_margin_top


func height_if_some(texture: Texture2D) -> float:
	if texture:
		return texture.get_height()
	else:
		return 0
