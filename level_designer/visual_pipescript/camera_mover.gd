extends Panel

onready var camera = $"/root/Main/Camera"

var is_being_held_down = false

func _on_Graph_gui_input(event):
	if event is InputEventMouseMotion && is_being_held_down:
		camera.position -= event.relative
	if event.is_action_pressed("ld_place"):
		is_being_held_down = true
	if event.is_action_released("ld_place"):
		is_being_held_down = false
