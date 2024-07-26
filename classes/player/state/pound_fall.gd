extends PlayerState


func _on_enter(_h):
	_anim(&"pound_fall")
	motion.set_vel_component(Vector2.DOWN, 8)


func _trans_rules():
	if actor.is_on_floor():
		return &"PoundLand"
	return &""
