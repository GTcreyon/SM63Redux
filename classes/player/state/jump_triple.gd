extends JumpFlip


func _trans_rules():
	if input.buffered_input(&"dive"):
		return &"Dive"
	return super()
