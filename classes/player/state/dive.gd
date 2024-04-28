extends AirborneState


func _on_enter(_h):
	var x_speed = abs(motion.vel.x)
	var accel_value = 7 - x_speed / 5
	motion.legacy_accel_x(accel_value * motion.get_facing(), true)
	motion.legacy_accel_y(3, true)
	_anim(&"dive_start")


func _anim_finished():
	if _last_anim == &"dive_start":
		_anim(&"dive_air")


func _cycle_tick():
	super()
	motion.apply_gravity(1.0, true)
	if motion.vel.y > 0:
		motion.legacy_friction_y(0.2, 1.05)
	else:
		motion.legacy_friction_y(0, 1.001)
	var target = atan2(motion.vel.y, motion.vel.x) + PI / 2 * (1 - motion.get_facing())
	motion.set_rotation(lerp_angle(motion.get_rotation(), target, 0.5))


func _on_exit():
	motion.set_rotation(0)


func _tell_switch():
	if actor.is_on_floor():
		return &"Idle"
	return &""
