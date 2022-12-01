class_name Interactable
extends Area2D
# Root class for objects that can be interacted with by entering an area and performing an action.

export var disabled: bool = false setget set_disabled
export(NodePath) var sprite

func _ready():
	if !Engine.editor_hint:
		sprite = get_node(sprite) as Node2D


func _physics_process(_delta):
	_physics_override()


func _physics_override():
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
