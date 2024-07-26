class_name JumpFlip
extends JumpState
## Flip jump. Used for either triple jumps or backflips.
## Adds horizontal velocity, and triggers a flipping animation.

## Number of full rotations to perform when flipping.
@export var _full_rotations: float = 2

## Number of full rotations to perform when flipping with fludd.
@export var _full_rotations_fludd: float = 1

## Time in frames that the flip should last.
@export var _flip_time: int = 54

## X velocity to add.
@export var _x_vel: float = 3.0

## Half the flip time - used for the transition animation.
@onready var _flip_time_half: int = _flip_time / 2

## Progress through the flip in frames.
var _flip_frames: int = 0


func _on_enter(_h):
	super(_h)
	_flip_frames = 0
	var current_speed = abs(motion.vel.x) * sign(_x_vel) * 1.875
	var accel_value = _x_vel - current_speed / 5
	motion.legacy_accel_x(accel_value * motion.get_facing(), true)


func _all_ticks():
	super()
	# Tick the flip timer up
	_flip_frames += 1
	
	var rotation_num = _full_rotations
	# TODO: Flip slower if wearing FLUDD
	#if current_nozzle != Singleton.Nozzles.NONE:
		#rotation_num = _full_rotations_fludd
	
	var progress = float(_flip_frames) / _flip_time
	var rotation = motion.get_facing() * rotation_num * TAU * ease_out_quart(progress)
	motion.set_rotation(rotation)
	
	if _flip_frames == _flip_time_half:
		_anim(trans_anims[_anim_index])
	elif _flip_frames < _flip_time_half:
		# Select the sprite with the correct lighting direction.
		actor.sprite.frame = int(abs(rotation) / PI * 2 + 0.5) % 4


func ease_out_quart(x: float) -> float:
	return 1 - pow(1 - x, 4) # https://easings.net/#easeOutQuart


func _on_exit():
	motion.set_rotation(0)


func _anim_finished():
	# Switch to the falling animation if the transition is done.
	if _last_anim in trans_anims:
		_anim(&"fall")


func _trans_rules():
	if input.buffered_input(&"pound"):
		return &"PoundWindup"

	if _flip_frames >= _flip_time:
		return [&"Fall", [&"fall", stylish]]
	return &""
