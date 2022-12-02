class_name DejitterGroup, "./dejitter_group.svg"
extends Node2D

export var dejitter_position = Vector2.ZERO

onready var parent = get_parent()
var last_pos : Vector2

func _physics_process(_delta):
	var offset_vec : Vector2
	var carrier_node = get_node(get_path()) # Get the current node
	if carrier_node is AnimatedSprite:
		var frames = carrier_node.frames
		var frame_num = carrier_node.frame
		var animation = carrier_node.animation
		
		offset_vec = frames.get_frame(animation, frame_num).get_size().posmod(2) / 2
	else:
		if carrier_node.get("texture") == null:
			offset_vec = Vector2.ZERO
		else:
			offset_vec = carrier_node.texture.get_size().posmod(2) / 2
	offset_vec += dejitter_position
	
	if parent.global_position.x == last_pos.x:
		global_position.x = round(parent.global_position.x) + offset_vec.x
	if parent.global_position.y == last_pos.y:
		global_position.y = round(parent.global_position.y) + offset_vec.y
	last_pos = parent.global_position
