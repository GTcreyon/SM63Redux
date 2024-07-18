extends PlayerState

## Horizontal acceleration
const ACCEL: float = 0.50

## Maximum horizontal speed
const MAX_SPEED: float = 3.5


func _all_ticks():
	motion.walk(input.get_x(), ACCEL, MAX_SPEED)


func _trans_rules():
	if input.buffered_input(&"jump"):
		return &"DummyJump"
	if not actor.is_on_floor():
		return &"SpinAir"
	return &""
