extends JumpFlip


func _tell_switch():
	if input.buffered_input(&"dive"):
		return &"Dive"
	return super()
