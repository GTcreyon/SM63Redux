extends PlayerState


func _trans_rules():
	if actor.is_on_floor():
		return &"Floor"

	if Input.is_action_just_pressed(&"jump"):
		if motion.active_coyote_time():
			return &"Jump"

	return &""


func _defer_rules():
	return &"Fall"


func _on_enter(handover):
	if handover == null:
		motion.consume_coyote_timer()
		return

	if handover is bool:
		if handover:
			motion.activate_coyote_timer()
		return
	push_warning("Unhandled handover of type \"%s\", value \"%s\"." % [typeof(handover), handover])
