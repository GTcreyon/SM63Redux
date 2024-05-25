extends PlayerState

const QUARTER_CIRCLE = TAU * 0.25

@onready var _angle_cast: RayCast2D = %SlideCast

func _on_enter(_h):
	actor.sprite.offset = Vector2(0, 8)
	_anim(&"dive_slide")


func _all_ticks():
	motion.legacy_friction_x(0.2, 1.05)
	if _angle_cast.is_colliding():
		var target = _get_slide_angle()
		motion.set_rotation(lerp_angle(motion.get_rotation(), target, 0.5))
	else:
		motion.set_rotation(QUARTER_CIRCLE)

	var abs_vel = abs(motion.vel.x)
	if abs_vel > 0.125:
		actor.sprite.speed_scale = min(abs_vel * 0.4, 2.0)
	else:
		actor.sprite.speed_scale = 0


## Returns the angle of the floor below
func _get_slide_angle() -> float:
	return _angle_cast.get_collision_normal().angle() + QUARTER_CIRCLE


func _on_exit():
	motion.set_rotation(0)
	actor.sprite.offset = Vector2(0, 0)
	actor.sprite.speed_scale = 1


func _trans_rules():
	if Input.is_action_pressed(&"jump"):
		if input.get_x_dir() == motion.get_facing():
			return &"Rollout"
		if input.get_x_dir() == -motion.get_facing():
			return &"Backflip"
		return &"Rollout"

	if not Input.is_action_pressed(&"dive") and abs(motion.vel.x) < 1:
		return &"Idle"
	return &""
