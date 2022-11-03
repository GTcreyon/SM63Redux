class_name InteractableDialog
extends Interactable
# Parent class for interactable objects that respond with dialog.

export(Array, String, MULTILINE) var lines = [""]
export var x_offset: int = 0

onready var dialog = $"/root/Main/Player/Camera/GUI/DialogBox"


func _interact_with(body):
	body.sign_x = global_position.x + x_offset * sign(body.position.x - global_position.x)
	body.vel = Vector2.ZERO
	body.locked = true
	body.sign_frames = 1
	dialog.load_lines(lines)
