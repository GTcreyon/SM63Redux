extends PlayerState


func _cycle_tick():
	motion.decel(0.65)


func _tell_defer():
	return &"Stand"


func _tell_switch():
	if input.buffered_input(&"jump"):
		return &"DummyJump"
	if input.buffered_input(&"spin"):
		return &"Spin"
	if input.is_moving_x():
		return &"Walk"
	if Input.is_action_pressed(&"dive"):
		return &"Crouch"
	return &""
