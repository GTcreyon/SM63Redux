extends PlayerState

var _done: bool = false

func _on_enter(_h):
	_done = false
	_anim(&"crouch_start")


func _all_ticks():
	if Input.is_action_just_released(&"down"):
		_anim(&"crouch_end")


func _anim_finished():
	if _last_anim == &"crouch_end":
		_done = true


func _trans_rules():
	if _done:
		return &"Idle"
	if input.buffered_input(&"jump"):
		return &"Backflip"
	return &""
