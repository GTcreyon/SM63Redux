extends PlayerState


func _on_enter(handover):
	_anim(&"hurt_start")
	var direction = -1
	if handover is int or handover is float:
		direction = handover
	motion.vel = Vector2(3 * direction, -3)
	motion.set_facing(-direction)


func _all_ticks():
	motion.apply_gravity(1.0, true)
	if motion.vel.y > 0:
		motion.legacy_friction_y(0.2, 1.05)


func _anim_finished():
	if _last_anim == &"hurt_start":
		_anim(&"hurt_loop")


func _trans_rules():
	if actor.is_on_floor():
		return &"Idle"
	return &""
