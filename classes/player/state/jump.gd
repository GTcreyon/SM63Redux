class_name JumpState
extends AirborneState
## Generic jump state. 


## Upwards velocity added when jumping
@export var jump_power: float = 10

## Ordinal number of this jump. 0 = Single, 1 = Double, 2 = Triple
@export var jump_number: int = 0

## ID of fall state to transition into
@export var fall_state := &"Fall"

## Possible animations to play to start the jump
@export var start_anims: PackedStringArray

## Possible animations to play to transition into falling
@export var trans_anims: PackedStringArray

## If true, don't automatically switch to the fall state.
@export var manual_fall: bool

## Whether or not the landing will result in a stylish animation.
@export var stylish: bool

## Index of the animation being used for the jump
var _anim_index: int


func _on_enter(_handover):
	_anim_index = randi_range(0, start_anims.size() - 1)
	_anim(start_anims[_anim_index])
	motion.legacy_accel_y(-jump_power, true)
	motion.consec_jumps = jump_number


func _post_tick():
	if Input.is_action_pressed("jump"):
		motion.legacy_accel_y(-0.2, false)
	motion.apply_gravity(1.0, true)
	if motion.vel.y > 0:
		motion.legacy_friction_y(0.2, 1.05)
	else:
		motion.legacy_friction_y(0, 1.001)


func _tell_switch():
	if Input.is_action_just_pressed(&"dive") and motion.can_air_action():
		return &"Dive"

	if input.buffered_input(&"spin"):
		return &"Spin"

	if Input.is_action_just_pressed(&"pound") and motion.can_air_action():
		return &"PoundSpin"

	if not manual_fall and motion.vel.y > 0:
		return [fall_state, [trans_anims[_anim_index], stylish]]

	return &""
