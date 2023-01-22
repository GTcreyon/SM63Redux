class_name Interactable
extends Area2D
# Root class for objects that can be interacted with by entering an area and performing an action.

export var disabled: bool = false setget set_disabled
export(NodePath) onready var sprite = get_node(sprite) as Node2D


func _physics_process(_delta):
	_physics_override()


func _physics_override():
	if !disabled:
		# NOTE: get_overlapping_bodies() throws errors if run
		# while monitoring is false.
		# This is why we only run the loop if not disabled.
		for body in get_overlapping_bodies():
			if _interact_check() and _state_check(body):
				_interact_with(body)


func _interact_with(_body):
	pass


func _interact_check() -> bool:
	return Input.is_action_just_pressed("interact")


func _state_check(body) -> bool:
	return body.state == body.S.NEUTRAL and body.sign_frames <= 0


func set_disabled(val):
	disabled = val
	monitoring = !val
