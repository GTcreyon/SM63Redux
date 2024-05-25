extends PlayerState


func _defer_rules():
	if actor.is_on_floor():
		return &"Floor"
	else:
		return &"Air"
