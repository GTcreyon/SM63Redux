extends PlayerState


func _on_enter(_h):
	motion.activate_consec_timer()


func _tell_switch():
	if not actor.is_on_floor():
		return [&"Air", true]

	return &""


func _tell_defer():
	return &"Idle"
