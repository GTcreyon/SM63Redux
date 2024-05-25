extends JumpFlip


func _trans_rules():
	if input.buffered_input(&"dive"):
		return &"Dive"
	if _flip_frames >= _flip_time_half and input.buffered_input(&"spin"):
		return &"Spin"
	return super()
