class_name Walk
extends PlayerState
## Moving left and right on the ground.


func _cycle_tick():
	motion.motion_x(false)
	actor.doll.speed_scale = actor.vel.x / motion.max_speed * 2


func _on_exit():
	actor.doll.speed_scale = 1


func _tell_switch():
	if input.buffered_input(&"jump"):
		return &"DummyJump"

	if input.buffered_input(&"spin") and motion.can_spin():
		return &"Spin"

	if Input.is_action_just_pressed(&"dive"):
		return &"Dive"

	if !input.is_moving_x():
		return &"Idle"

	if Input.is_action_pressed(&"down"):
		return &"Crouch"

	return &""
