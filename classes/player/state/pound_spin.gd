extends PlayerState

const FULL_DURATION: float = 18
const SPIN_DURATION: float = 9

## How many frames the player will be rising during the pound spin.
const RISE_TIME: float = 15
## How much the player rises each frame.
const RISE_RATE: float = 1

var progress: float


func _on_enter(_h):
	_anim(&"flip")
	progress = 0.0
	motion.set_vel(Vector2.ZERO)


func _all_ticks():
	progress += 1.0
	
	# Rotation animation.
	if progress <= SPIN_DURATION:
		motion.set_rotation(ease(progress / SPIN_DURATION, 0.5) * TAU * motion.get_facing())
	
	# A little rising during the wind-up makes it look real nice.
	# This feels best if it affects the literal, physical position of the player
	# (so that when they appear to rise above a platform, they actually do).
	if progress <= RISE_TIME:
		motion.set_vel_component(Vector2.DOWN, -RISE_RATE)


func _trans_rules():
	if progress > FULL_DURATION:
		motion.set_vel_component(Vector2.DOWN, 10.0)
		return &"PoundFall"
	return &""
