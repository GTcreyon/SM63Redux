extends PlayerState


func _trans_rules():
	if input.buffered_input(&"spin"):
		return &"SpinWater"
	return &""
