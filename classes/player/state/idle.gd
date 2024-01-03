extends PlayerState


func _post_tick():
	if abs(motion.get_vel_component(motion.x)) > 2.0:
		motion.decel(0.5)


func _tell_switch():
	if input.buffered_input(&"jump"):
		return &"DummyJump"
	return &""
