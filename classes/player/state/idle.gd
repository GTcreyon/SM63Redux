extends PlayerState


func _on_enter(_handover):
	_anim("walk_start")


func _cycle_tick():
	motion.decel(0.65)
	if motion.vel.x == 0:
		actor.sprite.frame = 0
	else:
		actor.sprite.speed_scale = motion.vel.x / 6.0 * 2.0


func _tell_switch():
	if input.buffered_input(&"jump"):
		return &"DummyJump"
	if input.is_moving_x():
		return &"Walk"
	return &""
