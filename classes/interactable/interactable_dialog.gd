class_name InteractableDialog
extends Interactable
# Parent class for interactable objects that respond with dialog.

export(Array, String, MULTILINE) var lines = [""]
export var x_offset: int = 0
export var can_pivot: bool = false

onready var dialog = $"/root/Main/Player/Camera/GUI/DialogBox"


func _interact_with(body):
	var side = sign(body.global_position.x - global_position.x)
	
	# Don't flip the player if no movement happens
	if side != 0:
		body.sprite.flip_h = side == 1
		
		# Flip the object to face the player if allowed to
		if can_pivot:
			sprite.flip_h = side == -1
	
	body.read_pos_x = global_position.x + x_offset * side
	body.vel = Vector2.ZERO
	body.locked = true
	body.sign_frames = 1
	
	dialog.load_lines(lines)
