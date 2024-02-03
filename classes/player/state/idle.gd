extends PlayerState


func _post_tick():
	motion.friction_x(0.3, 1.15)


func _tell_switch():
	if input.buffered_input(&"jump"):
		return &"DummyJump"
	if input.is_moving_x():
		return &"Walk"
	return &""
