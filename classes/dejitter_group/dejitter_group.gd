@icon("./dejitter_group.svg")
class_name DejitterGroup
extends Node2D
# DejitterGroup ensures that when a visible object is stationary,
# its pixels are always exactly aligned with world pixels.

# DejitterGroup overwrites the object's position.
# This variable exists so the objects in the group can still have
# their positions adjusted from code.
@export var dejitter_position = Vector2.ZERO

@onready var parent = get_parent()
var last_pos: Vector2


func _physics_process(_delta):
	# Find offset needed to fit uneven-sized sprites to the grid
	var offset_vec: Vector2
	var carrier_node = get_node(get_path()) # Get the current node
	if carrier_node is AnimatedSprite2D:
		# Set offset relative to current frame of animation
		var frames = carrier_node.frames
		var frame_num = carrier_node.frame
		var animation = carrier_node.animation
		
		offset_vec = frames.get_frame(animation, frame_num).get_size().posmod(2) / 2
	else:
		if carrier_node.get("texture") == null:
			# No texture, so no offset needed
			offset_vec = Vector2.ZERO
		else:
			# Set offset relative to entire texture
			offset_vec = carrier_node.texture.get_size().posmod(2) / 2
	# Apply user-defined offset on top of uneven-size offset
	offset_vec += dejitter_position
	
	# If parent hasn't moved, place this object on the world grid
	if parent.global_position.x == last_pos.x:
		global_position.x = round(parent.global_position.x) + offset_vec.x
	if parent.global_position.y == last_pos.y:
		global_position.y = round(parent.global_position.y) + offset_vec.y
	
	# Save parent's position to check next frame
	last_pos = parent.global_position
