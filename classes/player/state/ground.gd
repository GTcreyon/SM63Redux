extends PlayerState


func _on_enter(_h):
	motion.activate_consec_timer()


func _trans_rules():
	if not actor.is_on_floor():
		return [&"Air", true]

	return &""


func _defer_rules():
	return &"Idle"
