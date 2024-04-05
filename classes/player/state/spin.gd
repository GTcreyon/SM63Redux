extends PlayerState

## Length in frames of the attacking phase of the spin
const STRIKE_PERIOD: int = 30

## Time taken for the harmless phase of the spin to fully slow down
const SOFT_PERIOD: int = 60

## Initial animation speed of the soft phase
const SOFT_START_SPEED: float = 1.0

## Final animation speed of the soft phase
const SOFT_END_SPEED: float = 0.4

## Remaining time in the strike phase
var _strike_time: int

## Remaining time in the soft phase
var _soft_time: int


func _on_enter(_h):
	_strike_time = STRIKE_PERIOD
	_soft_time = SOFT_PERIOD
	_anim("spin_start")


func _anim_finished():
	if _last_anim == "spin_start":
		_anim("spin_fast")


func _cycle_tick():
	if _strike_time > 0:
		_strike_time -= 1
		if _strike_time == 0:
			var save_frame = actor.sprite.frame
			_anim("spin_slow")
			actor.sprite.frame = save_frame
	else:
		if _soft_time > 0:
			_soft_time -= 1
		var spin_progress: float = 1 - (_soft_time / SOFT_PERIOD)
		var move_mod: float = 1 + min(abs(motion.vel.x / 5), 1)
		# Lerp speed from fast at the start, to slow at the sustain.
		actor.sprite.speed_scale = lerpf(SOFT_START_SPEED, SOFT_END_SPEED, spin_progress) * move_mod


func _tell_switch():
	if !Input.is_action_pressed("spin") and _strike_time <= 0:
		return &"Neutral"
	return &""
