class_name SpinState
extends PlayerState

## Total length of the spin in frames.
const FULL_LENGTH: int = 48.0

## Time in frames for the harmless phase of the spin to fully slow down.
const SOFT_TIME: int = 24.0

## Initial animation speed of the soft phase
const SOFT_START_SPEED: float = 1.0

## Final animation speed of the soft phase
const SOFT_END_SPEED: float = 0.4

## [Area2D] used to check for water.
@export var water_check: Area2D

## [Hitbox] used to strike enemies.
@export var strike_hitbox: Hitbox

## If true, this state handles behavior in water.
@export var in_water: bool = false

## Remaining time in the spin.
var _time: float


func _on_enter(_h):
	_start_spin()


func _start_spin():
	_time = FULL_LENGTH
	_anim(&"spin_start")
	strike_hitbox.start_hit()


func _anim_finished():
	if _last_anim == &"spin_start":
		_anim(&"spin_fast")


func _all_ticks():
	if _time > 0:
		_time -= 1

	if _time == SOFT_TIME:
		strike_hitbox.stop_hit()
		var save_frame = actor.sprite.frame
		_anim(&"spin_slow")
		actor.sprite.frame = save_frame
	elif _time < SOFT_TIME:
		var spin_progress: float = 1 - (float(_time) / SOFT_TIME)
		var move_mod: float = 1 + min(abs(motion.vel.x / 5), 1)
		# Lerp speed from fast at the start, to slow at the sustain.
		actor.sprite.speed_scale = lerpf(SOFT_START_SPEED, SOFT_END_SPEED, spin_progress) * move_mod


func _on_exit():
	actor.sprite.speed_scale = 1
	strike_hitbox.stop_hit()


func _defer_rules():
	if not water_check.get_overlapping_areas().is_empty():
		return &"SpinWater"
	if actor.is_on_floor():
		return &"SpinFloor"
	return &"SpinAir"


func _trans_rules():
	if not Input.is_action_pressed(&"spin") and _time <= SOFT_TIME:
		# Include a delay while in the air to prevent unlimited spinning
		if not water_check.get_overlapping_areas().is_empty():
			return &"Swim"
		if actor.is_on_floor() or _time <= 0:
			return &"Neutral"

	if not water_check.get_overlapping_areas().is_empty():
		return &"SpinWater"
	if actor.is_on_floor():
		return &"SpinFloor"
	return [&"SpinAir", false]
