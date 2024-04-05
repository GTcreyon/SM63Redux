class_name LandState
extends PlayerState
## State for landing on the ground after falling.

## The animation to use when landing.
@export var animation: StringName

## If true, the state should end and return to a standing state.
var _done: bool


func _on_enter(_h):
	_done = false
	_anim(animation)


func _anim_finished():
	_done = true


func _tell_switch():
	if _done:
		return &"Stand"
	return &""
