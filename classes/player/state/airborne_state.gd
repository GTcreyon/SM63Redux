class_name AirborneState
extends PlayerState

const HORIZONTAL_MAX_VEL: float = 2.65
const HORIZONTAL_ACCEL: float = 0.34
const HORIZONTAL_DECEL: float = 0.001


func _cycle_tick():
	var x_dir = input.get_x()
	if x_dir == 0:
		# Decelerate if there's no input.
		motion.decel(HORIZONTAL_DECEL)
	elif x_dir != sign(motion.vel.x):
		# Decelerate a lot to return to neutral if we're changing directions.
		motion.decel(HORIZONTAL_ACCEL)
	motion.accel_x_capped(x_dir * HORIZONTAL_ACCEL, HORIZONTAL_MAX_VEL)
	_update_facing()
