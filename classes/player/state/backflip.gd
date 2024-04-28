extends JumpFlip

func _trans_rules():
	if input.buffered_input(&"dive") and _flip_frames > _flip_time_half:
		return &"Dive"
	return super()
