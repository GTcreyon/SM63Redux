extends Control

const SCROLL_SPEED = 9

onready var main = $"/root/Main"
onready var base = $ItemBlock/ItemDisplay/Back/Base
onready var grid = $ItemBlock/ItemDisplay/Back/Base/ItemGrid


func _on_LeftBar_gui_input(event):
	var full_height = ceil(main.items.size() / 2) * (32 + grid.get_constant("vseparation")) - grid.margin_left - base.rect_size.y + 2
	
	var factor
	if event.factor == 0:
		factor = 1
	else:
		factor = event.factor
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN:
			grid.margin_top = max(grid.margin_top - SCROLL_SPEED * factor, -full_height)
		if event.button_index == BUTTON_WHEEL_UP:
			grid.margin_top = min(grid.margin_top + SCROLL_SPEED * factor, grid.margin_left)
