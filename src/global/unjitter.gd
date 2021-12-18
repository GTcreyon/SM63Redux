extends Node2D

onready var parent = get_parent()
var last_pos : Vector2

func _physics_process(_delta):
	if parent.global_position.x == last_pos.x:
		global_position.x = round(parent.global_position.x)
	if parent.global_position.y == last_pos.y:
		global_position.y = round(parent.global_position.y)
	last_pos = parent.global_position
