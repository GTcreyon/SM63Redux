extends PlayerState


func _cycle_tick():
	if Input.is_action_pressed("jump"):
		motion.legacy_accel_y(-0.1, true)
	motion.apply_gravity(1.0, true)
	if motion.vel.y > 0:
		motion.legacy_friction_y(0.2, 1.05)
