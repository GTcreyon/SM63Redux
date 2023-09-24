extends Control

const SCROLL_SPEED = 9
const GRID_THEME_TYPE = ""

@onready var main = $"/root/Main"
@onready var base = $ItemBlock/ItemDisplay/Back/Base
@onready var grid = $ItemBlock/ItemDisplay/Back/Base/ItemGrid


func _on_LeftBar_gui_input(event):
	var full_height = ceil(main.items.size() / 2) * (32 + grid.theme.get_constant("v_separation", GRID_THEME_TYPE)) - grid.offset_left - base.size.y + 2
	
	var factor
	if event.factor == 0:
		factor = 1
	else:
		factor = event.factor
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			grid.offset_top = max(grid.offset_top - SCROLL_SPEED * factor, -full_height)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			grid.offset_top = min(grid.offset_top + SCROLL_SPEED * factor, grid.offset_left)
