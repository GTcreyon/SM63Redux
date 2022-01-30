extends Node2D

onready var parent = get_parent()
var last_pos : Vector2

func _physics_process(_delta):
	var offset_vec : Vector2
	if get("frames") == null:
		if get("texture") == null:
			offset_vec = Vector2.ZERO
		else:
			offset_vec = get("texture").get_size().posmod(2) / 2
	else:
		offset_vec = get("frames").get_frame(get("animation"), get("frame")).get_size().posmod(2) / 2
	
	if parent.global_position.x == last_pos.x:
		global_position.x = round(parent.global_position.x) + offset_vec.x
	if parent.global_position.y == last_pos.y:
		global_position.y = round(parent.global_position.y) + offset_vec.y
	last_pos = parent.global_position
