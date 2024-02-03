extends PlayerState


func _cycle_tick():
	motion.apply_gravity()
	#motion.motion_x()
