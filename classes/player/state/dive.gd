extends AirborneState


func _on_enter(_h):
	var x_speed = abs(motion.vel.x) * 1.875

	## Reimplements a mistake that allows backflip chaining to be possible
	## Only do this when moving backwards though, to avoid messing with regular dives
	if motion.get_facing() == -motion.get_x_direction() and x_speed > 5 * 1.875:
		x_speed *= 1.875

	var accel_value = 7 - x_speed / 5
	motion.legacy_accel_x(accel_value * motion.get_facing(), true)
	motion.legacy_accel_y(3, true)
	_anim(&"dive_start")


func _anim_finished():
	if _last_anim == &"dive_start":
		_anim(&"dive_air")


func _all_ticks():
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


func _trans_rules():
	if actor.is_on_floor():
		motion.move(Vector2(0, -10))
		return &"Slide"
	return &""
