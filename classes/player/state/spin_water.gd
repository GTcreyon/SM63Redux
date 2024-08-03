extends PlayerState

const DECEL = 0.125

const HORIZONTAL_ACCEL: float = 0.34
const VERTICAL_ACCEL: float = 0.34
const HORIZONTAL_MAX_VEL: float = 3.0
const VERTICAL_MAX_VEL: float = 2.0


func _all_ticks():
	super()

	var direction = Input.get_vector(&"left", &"right", &"swim", &"down")

	if direction.x == 0:
		motion.vel.x *= 0.875
	elif abs(motion.vel.x) > HORIZONTAL_MAX_VEL:
		motion.vel.x = move_toward(motion.vel.x, HORIZONTAL_MAX_VEL, DECEL)

	if direction.y == 0:
		motion.vel.y *= 0.875
	elif abs(motion.vel.y) > VERTICAL_MAX_VEL:
		motion.vel.y = move_toward(motion.vel.y, VERTICAL_MAX_VEL, DECEL)

	motion.accel_x_capped(direction.x * HORIZONTAL_ACCEL, HORIZONTAL_MAX_VEL)
	motion.accel_y_capped(direction.y * VERTICAL_ACCEL, VERTICAL_MAX_VEL)
	_update_facing()
