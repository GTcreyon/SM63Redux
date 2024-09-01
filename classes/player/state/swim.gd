extends PlayerState

const VERTICAL_ACCEL: float = 0.25
const VERTICAL_MAX_VEL: float = 3.0

const HORIZONTAL_MAX_VEL: float = 3.0
const HORIZONTAL_ACCEL: float = 0.25
const HORIZONTAL_DECEL: float = 0.1


func _on_enter(_h):
	_anim(&"swim_idle")


func _all_ticks():
	var input_x = Input.get_axis(&"left", &"right")
	var input_y = Input.get_axis(&"swim", &"dive")
	var target_vel_y = VERTICAL_MAX_VEL * input_y
	if input_y < 0:
		if motion.vel.y > target_vel_y:
			motion.vel.y = max(target_vel_y, motion.vel.y + VERTICAL_ACCEL * input_y)
		if _last_anim == &"swim_idle":
			_anim(&"swim_stroke_start")
	elif input_y > 0:
		if motion.vel.y < target_vel_y:
			motion.vel.y = min(target_vel_y, motion.vel.y + VERTICAL_ACCEL * input_y)
	else:
		motion.accel_y_capped(0.0625, 1.5)

	if Input.is_action_just_released(&"swim"):
		_anim(&"swim_stroke_end")
		if motion.vel.y < 0:
			motion.vel.y *= 0.5

	if input_x == 0 or abs(motion.vel.x) > HORIZONTAL_MAX_VEL:
		# Decelerate if there's no input.
		motion.decel(HORIZONTAL_DECEL)
	motion.accel_x_capped(input_x * HORIZONTAL_ACCEL, HORIZONTAL_MAX_VEL)
	_update_facing()


func _anim_finished():
	match _last_anim:
		&"swim_stroke_start", &"swim_stroke_loop":
			if Input.is_action_pressed(&"swim"):
				_anim(&"swim_stroke_loop")
			else:
				_anim(&"swim_stroke_end")
		&"swim_stroke_end":
			_anim(&"swim_idle")


func _trans_rules():
	if input.buffered_input(&"pound"):
		return &"WaterBoost"
	if input.buffered_input(&"spin"):
		return &"SpinWater"
	return &""
