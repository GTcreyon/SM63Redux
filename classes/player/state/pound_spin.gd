extends PlayerState

const FULL_DURATION: float = 18
const SPIN_DURATION: float = 9

var progress: float


func _on_enter(_h):
	_anim(&"flip")
	progress = 0.0
	motion.set_vel(Vector2.ZERO)


func _all_ticks():
	progress += 1.0
	if progress <= SPIN_DURATION:
		motion.set_rotation(ease(progress / SPIN_DURATION, 0.5) * TAU * motion.get_facing())


func _trans_rules():
	if progress > FULL_DURATION:
		motion.set_vel_component(Vector2.DOWN, 10.0)
		return &"PoundFall"
	return &""
