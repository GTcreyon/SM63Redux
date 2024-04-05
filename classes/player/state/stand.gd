extends PlayerState

func _on_enter(_handover):
	_anim(&"walk_start")


func _cycle_tick():
	if motion.vel.x == 0:
		actor.sprite.frame = 0
	else:
		actor.sprite.speed_scale = motion.vel.x / 6.0 * 2.0


func _on_exit():
	actor.sprite.speed_scale = 1
