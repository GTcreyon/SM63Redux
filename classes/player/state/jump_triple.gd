class_name JumpTriple
extends JumpState
## Triple jump. Jumps higher than single or double, and triggers a flip animation.

const FLIP_TIME: int = 54
const FLIP_TIME_HALF: int = 27
var _flip_frames: int = 0

func _on_enter(_h):
	super(_h)
	_flip_frames = 0
	var adjusted_xvel = abs(motion.vel.x) * 1.875
	var accel_value = 3 - adjusted_xvel / 5
	motion.legacy_accel_x(accel_value * input.get_x_dir(), true)


func _cycle_tick():
	super()
	# Tick the flip timer up
	_flip_frames += 1
	
	var spin_speed = 2
	# TODO: Flip slower if wearing FLUDD
	#if current_nozzle != Singleton.Nozzles.NONE:
		#spin_speed = 1
	
	var progress = float(_flip_frames) / FLIP_TIME
	var rotation = motion.get_axis_direction(motion.x) * spin_speed * TAU * ease_out_quart(progress)
	motion.set_rotation(rotation)
	
	if _flip_frames == FLIP_TIME_HALF:
		_anim(&"jump_double_trans")
	elif _flip_frames < FLIP_TIME_HALF:
		# Select the sprite with the correct lighting direction.
		actor.sprite.frame = int(abs(rotation) / PI * 2 + 0.5) % 4


func ease_out_quart(x: float) -> float:
	return 1 - pow(1 - x, 4) # https://easings.net/#easeOutQuart


func _on_exit():
	motion.set_rotation(0)


func _anim_finished():
	if _last_anim == &"jump_double_trans":
		_anim(&"fall")


func _tell_switch():
	if _flip_frames >= FLIP_TIME:
		return [&"Fall", [&"fall", stylish]]
	return super()
