extends PlayerState

const DURATION: int = 12

const BURST_SPEED = 8.0
const NEUTRAL_SPEED = 3.0
const DECEL = 0.25

const EASE_CURVE: float = 0.5

@export var water_check: Area2D

var _time: int


func _on_enter(_h):
	_dash()


func _dash() -> void:
	# TODO: Consume air to do this.
	var direction = Input.get_vector(&"left", &"right", &"up", &"down")
	_anim(&"flip")
	_time = 0
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT * motion.get_facing()
	motion.vel = direction * BURST_SPEED


func _all_ticks():
	_time += 1

	if input.buffered_input(&"pound"):
		_dash()

	var spin_fac = ease(float(_time) / float(DURATION), EASE_CURVE)
	motion.set_rotation(spin_fac * TAU * motion.get_facing())
	
	motion.vel = motion.vel.normalized() * (motion.vel.length() - DECEL)


func _on_exit():
	motion.set_rotation(0)
	var remaining_frames = DURATION - _time
	motion.vel = motion.vel.normalized() * (motion.vel.length() - DECEL * remaining_frames * 0.125)


func _trans_rules():
	if water_check.get_overlapping_areas().is_empty():
		return &"Air"
	if _time >= DURATION:
		return &"Swim"
	if input.buffered_input(&"spin"):
		return &"SpinWater"
	return &""
