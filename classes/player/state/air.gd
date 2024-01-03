extends PlayerState

const COYOTE_DURATION: int = 6

var _coyote_remaining: int = 0


func _tell_switch():
	if actor.is_on_floor():
		return &"Ground"

	if Input.is_action_just_pressed(&"jump"):
		if _coyote_remaining > 0:
			return &"Jump"

	return &""


func _tell_defer():
	return &"Fall"


func _on_enter(handover):
	if handover == null:
		_coyote_remaining = 0
		return

	if handover is bool:
		if handover:
			_coyote_remaining = COYOTE_DURATION
		return
	push_warning("Unhandled handover of type \"%s\", value \"%s\"." % [typeof(handover), handover])
