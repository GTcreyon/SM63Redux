extends PlayerState


func _trans_rules():
	if actor.is_on_floor():
		return &"PoundLand"
	return &""
