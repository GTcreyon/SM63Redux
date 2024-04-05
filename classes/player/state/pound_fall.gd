extends PlayerState


func _tell_switch():
	if actor.is_on_floor():
		return &"PoundLand"
	return &""
