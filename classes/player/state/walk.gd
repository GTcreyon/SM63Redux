class_name Walk
extends PlayerState
## Moving left and right on the ground.

const WALK_ACCEL: float = 0.50
const WALK_SPEED: float = 3.5


func _on_enter(_handover):
	_anim(&"walk_start")


func _anim_finished():
	if _last_anim == &"walk_start":
		_anim(&"walk_loop")


func _all_ticks():
	motion.walk(input.get_x(), WALK_ACCEL, WALK_SPEED)
	actor.sprite.speed_scale = motion.vel.x / 6.0 * 2.0


func _on_exit():
	actor.sprite.speed_scale = 1


func _trans_rules():
	if input.buffered_input(&"jump"):
		return &"DummyJump"

	if input.buffered_input(&"spin"):
		return &"Spin"

	if Input.is_action_pressed(&"dive"):
		return &"Slide"

	if !input.is_moving_x():
		return &"Idle"

	if Input.is_action_pressed(&"down"):
		return &"Crouch"

	return &""
