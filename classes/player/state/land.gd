class_name LandState
extends PlayerState
## State for landing on the ground after falling.


@export var animation: StringName

var _finished: bool


func _on_enter(_h):
	_finished = false
	_anim(animation)


func _anim_finished():
	_finished = true


func _tell_switch():
	if _finished:
		return &"Idle"
	return &""
