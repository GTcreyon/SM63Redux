class_name DecoratedScrollContainer
extends ScrollContainer
## Scroll container which uses decorated scrollbars.

const V_BAR_SCRIPT = preload("res://scenes/menus/level_designer/widgets/v_scroll_bar_decorated.gd")


# Called when the node enters the scene tree for the first time.
func _ready():
	var v_scroller = get_v_scroll_bar()
	v_scroller.theme = self.theme
	v_scroller.set_script(V_BAR_SCRIPT)
	(v_scroller as VScrollBarDecorated)._ready()
