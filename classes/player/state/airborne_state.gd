class_name AirborneState
extends PlayerState

## Divisor that applies friction to aerial motion.
@export var friction_divisor: float = 1.0

## If true, the player can turn around to face the other direction.
@export var allow_turnaround: bool = true

## If true, horizontal deceleration will be much faster.
@export var tight_movement: bool = false

const HORIZONTAL_MAX_VEL: float = 2.65
const HORIZONTAL_ACCEL: float = 0.34
const HORIZONTAL_DECEL: float = 0.001


func _all_ticks():
	var x_accel = HORIZONTAL_ACCEL / pow(friction_divisor, 1.875)
	var x_dir = input.get_x()
	if x_dir == 0:
		# Decelerate if there's no input.
		motion.decel(HORIZONTAL_DECEL)
	elif x_dir != sign(motion.vel.x) and tight_movement:
		# Decelerate a lot to return to neutral if we're changing directions.
		motion.decel(x_accel)
	motion.accel_x_capped(x_dir * x_accel, HORIZONTAL_MAX_VEL)
	if allow_turnaround:
		_update_facing()
