class_name JumpState
extends AirborneState
## Generic jump state. 


## Upwards velocity added when jumping
@export var jump_power: float = 10

## Ordinal number of this jump. 0 = Single, 1 = Double, 2 = Triple
@export var jump_number: int = 0

## Possible animations to play to start the jump
@export var start_anims: PackedStringArray

## Possible animations to play to transition into falling
@export var trans_anims: PackedStringArray

## If true, the landing will result in a stylish animation.
@export var stylish: bool = false

## If true, jump height can be modulated by holding down the jump button.
@export var allow_modulation: bool = false

## Index of the animation being used for the jump
var _anim_index: int


func _on_enter(_h):
	motion.legacy_accel_y(-jump_power, true)
	motion.consec_jumps = jump_number
	_anim_index = randi_range(0, start_anims.size() - 1)
	_anim(start_anims[_anim_index])


func _post_tick():
	if Input.is_action_pressed("jump") and allow_modulation:
		motion.legacy_accel_y(-0.2, false)
	motion.apply_gravity(1.0, true)
	if motion.vel.y > 0:
		motion.legacy_friction_y(0.2, 1.05)
	else:
		motion.legacy_friction_y(0, 1.001)
