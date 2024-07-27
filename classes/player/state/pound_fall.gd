extends PlayerState

@export var pound_hitbox: Hitbox = null


func _on_enter(_h):
	pound_hitbox.start_hit()
	_anim(&"pound_fall")


func _all_ticks():
	# If we get slowed down, need to speed back up again.
	motion.accel_y_capped(motion.gravity, 10.0)


func _on_exit():
	pound_hitbox.stop_hit()


func _trans_rules():
	if actor.is_on_floor():
		return &"PoundLand"
	return &""
