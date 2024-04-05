extends PlayerState


func _tell_defer():
	if actor.is_on_floor():
		print("b")
		return &"Ground"
	else:
		print("c")
		return &"Air"
