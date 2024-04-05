extends PlayerState


func _tell_defer():
	if actor.is_on_floor():
		return &"Ground"
	else:
		return &"Air"
