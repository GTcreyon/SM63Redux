class_name Walk
extends PlayerState
## Moving left and right on the ground.

const WALK_ACCEL: float = 0.586667

func _cycle_tick():
	motion.friction_x(0.3, 1.15)
	motion.accel_x(WALK_ACCEL * input.get_x())
	actor.sprite.speed_scale = motion.vel.x / 6.0 * 2


func _on_exit():
	actor.sprite.speed_scale = 1


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
