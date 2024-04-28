extends PlayerState


func _all_ticks():
	motion.decel(0.65)


func _defer_rules():
	return &"Stand"


func _trans_rules():
	if input.buffered_input(&"jump"):
		return &"DummyJump"
	if input.buffered_input(&"spin"):
		return &"Spin"
	if input.is_moving_x():
		return &"Walk"
	if Input.is_action_pressed(&"dive"):
		return &"Crouch"
	return &""
