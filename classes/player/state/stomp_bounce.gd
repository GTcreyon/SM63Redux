extends PlayerState

## Full length of time in frames that the stomp takes.
const LENGTH: int = 18

## Half of the full length.
const HALF_LENGTH = LENGTH / 2

var _is_high: bool = false
var _time: int = 0


func _on_enter(handover):
	_anim(&"stomp_start")
	_time = 0
	_is_high = motion.consec_jumps == 2


func _all_ticks():
	# How far we are through the bounce.
	var progress = float(_time) / float(LENGTH)

	# Range between -1 and 1.
	var normalised_progress = (progress - 0.5) * 2

	# Derivative of an x^4 curve. Has a nice shape.
	var derivative = pow(normalised_progress, 3) * 4

	motion.set_vel_component(Vector2.UP, derivative)
	if _time > HALF_LENGTH:
		if _is_high:
			_anim(&"stomp_high")
		else:
			_anim(&"stomp_low")

	_time += 1


func _trans_rules():
	if _time >= LENGTH:
		if _is_high:
			return [&"JumpDouble", false]
		else:
			return [&"Jump", false]
	return &""


func _on_exit():
	motion.set_vel_component(Vector2.UP, 0)
