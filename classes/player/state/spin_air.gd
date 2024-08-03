extends AirborneState

const BOUNCE_VEL: float = 2.0
const FLOAT_PERIOD: float = 22.0

var _float_time: float = 0.0


func _on_enter(handover):
	_float_time = FLOAT_PERIOD
	var bounce = true
	if handover is bool:
		bounce = handover
	if bounce and motion.vel.y > -BOUNCE_VEL:
		motion.vel.y = 0
		motion.accel_y(-BOUNCE_VEL)


func _subsequent_ticks():
	var float_factor: float = 0.0
	if Input.is_action_pressed("jump"):
		motion.legacy_accel_y(-0.2)
	if motion.vel.y > 0:
		# Initial floatiness that decreases over time
		float_factor = _float_time / FLOAT_PERIOD
		motion.legacy_friction_y(lerp(0.1, 0.3, float_factor), lerp(1.03, 1.05, float_factor))
		_float_time = max(_float_time - 1.0, 0)

		# Regular air floatiness
		motion.legacy_friction_y(0.2, 1.05)
	motion.apply_gravity(1.0, true)


func _trans_rules():
	if input.buffered_input(&"dive"):
		return &"Dive"
	return &""
