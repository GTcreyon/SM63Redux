extends Camera2D

@onready var background = get_node("/root/Main/Background/BGGrid")

var is_being_held_down = false


func _input(event):
	if event is InputEventMouseMotion && is_being_held_down:
		position -= event.relative
		background.material.set_shader_parameter("camera_position", global_position)
	if event.is_action_pressed("ld_alt_click"):
		is_being_held_down = true
	if event.is_action_released("ld_alt_click"):
		is_being_held_down = false
