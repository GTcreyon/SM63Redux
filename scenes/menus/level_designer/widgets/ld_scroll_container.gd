class_name DecoratedScrollContainer
extends ScrollContainer
## Scroll container which uses decorated scrollbars.

const V_BAR_SCRIPT = preload("res://scenes/menus/level_designer/widgets/v_scroll_bar_decorated.gd")


# Called when the node enters the scene tree for the first time.
func _ready():
	get_v_scroll_bar().set_script(V_BAR_SCRIPT)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
