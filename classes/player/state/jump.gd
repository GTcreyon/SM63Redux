class_name Jump
extends PlayerState
## Generic jump state. 


## Upwards velocity added when jumping
@export var jump_power: float = 18.75

## Ordinal number of this jump. 0 = Single, 1 = Double, 2 = Triple
@export var jump_number: int = 0

## ID of fall state to transition into.
@export var fall_state := &"Fall"

## Set to `true` once height variation has been applied. Prevents re-application.
var _applied_variation: bool = false


func _on_enter(_handover):
	_applied_variation = false
	actor.vel.y = -jump_power

	motion.consec_jumps = jump_number


func _post_tick():
	motion.apply_gravity(-actor.vel.y / jump_power)


func _cycle_tick():
	motion.motion_x(false)
	_variable_height()


func _variable_height() -> void:
	var vel_y = motion.get_vel_component(motion.y)
	if Input.is_action_just_released("jump") and not _applied_variation:
		_applied_variation = true
		motion.set_vel_component(vel_y * 0.375, motion.y)


func _tell_switch():
	if Input.is_action_just_pressed(&"dive") and motion.can_air_action():
		return &"Dive"

	if input.buffered_input(&"spin") and motion.can_spin():
		return &"Spin"

	if Input.is_action_just_pressed(&"pound") and motion.can_air_action():
		return &"PoundSpin"

	if actor.vel.y > 0:
		return fall_state

	return &""
