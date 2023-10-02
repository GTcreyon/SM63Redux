extends Control

const SCROLL_SPEED = 9
const GRID_THEME_TYPE = ""

@onready var main = $"/root/Main"
@onready var base = $ItemBlock/ItemDisplay/Back/Base
@onready var grid = $ItemBlock/ItemDisplay/Back/Base/ItemGrid


func _on_LeftBar_gui_input(event):
	# Calculate the full height of all cells on top of each other.
	# Start with the total number of items.
	var full_height = ceil(main.items.size() / 2)
	# Find height of one cell plus padding.
	var cell_height = 32 + grid.theme.get_constant("v_separation", GRID_THEME_TYPE)
	full_height *= cell_height
	# Add some padding to the margins.
	# offset_top is the actual scrolled position; read offset_left instead.
	full_height -= grid.offset_left + base.size.y - 2
	
	# Cache the amount of movement in the checked event.
	# (If there's no amount listed, use 1.)
	var factor
	if event.factor == 0:
		factor = 1
	else:
		factor = event.factor
	
	# Shift grid down in response to mouse wheel events.
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			grid.offset_top = max(grid.offset_top - SCROLL_SPEED * factor, -full_height)
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			grid.offset_top = min(grid.offset_top + SCROLL_SPEED * factor, grid.offset_left)
