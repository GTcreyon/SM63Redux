extends Control

const SCROLL_SPEED = 9

onready var main = $"/root/Main"
onready var base = $Back/Base
onready var grid = $Back/Base/ItemGrid


func _on_ItemPane_gui_input(event):
	var height = ceil(main.items.size() / 2)
	var factor
	if event.factor == 0:
		factor = 1
	else:
		factor = event.factor
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN:
			grid.margin_top = max(grid.margin_top - SCROLL_SPEED * factor, (-height * (32 + 4) + 3) + base.rect_size.y - 2)
		if event.button_index == BUTTON_WHEEL_UP:
			grid.margin_top = min(grid.margin_top + SCROLL_SPEED * factor, 3)
