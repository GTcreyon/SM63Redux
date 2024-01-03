class_name Motion
extends Node
## Handles movement of the actor.

## Time delay allowed before cancelling a double/triple jump.
const CONSEC_JUMP_TIME: int = 8
const COYOTE_TIME: int = 5
const RESIST_DECREMENT: float = 1.0 / 20.0

## Target actor of this motion manager.
@export var actor: CharacterBody2D = owner
@export var gravity: float = 1.875
@export var term_vel: float = 4.0

var y = Vector2.DOWN
var x = y.orthogonal()
var vel := Vector2.ZERO
var vel_prev := Vector2.ZERO
var last_direction_x: int = 1
var resist: float = 0
var consec_jump_timer: int = 0
var coyote_timer: int = 0
var consec_jumps: int = 0


func _physics_process(delta):
	_move_actor(delta)
	resist = max(resist - RESIST_DECREMENT, 0)


## Move the actor using the stored `vel` value.
func _move_actor(delta: float) -> void:
	actor.velocity = vel / delta
	actor.move_and_slide()
	vel = actor.velocity * delta


## Apply downward acceleration.
func apply_gravity(multiplier: float = 1.0, cap: float = term_vel) -> void:
	var down_force = gravity
	if abs(vel.dot(y)) < 1:
		down_force *= 0.5
	accel_capped(Vector2(0, down_force * multiplier), cap)


## Activate the consecutive jump timer.
func activate_consec_timer() -> void:
	consec_jump_timer = CONSEC_JUMP_TIME


## Return whether the consecutive jump timer is or isn't running.
func active_consec_time() -> bool:
	return consec_jump_timer > 0


## Consume the consecutive jump timer, ridding of any chance at a consecutive jump.
func consume_consec_timer() -> void:
	consec_jump_timer = -1


## Activate the coyote timer.
func activate_coyote_timer() -> void:
	coyote_timer = COYOTE_TIME


## Return whether the coyote timer is or isn't running.
func active_coyote_time() -> bool:
	return coyote_timer > 0


## Consume the coyote timer, ridding of any chance at a coyote input.
func consume_coyote_timer() -> void:
	coyote_timer = 0


## Accelerate by a given velocity, up to a certain limit.
## If already above the limit due to external forces, this will not reduce speed.
func accel_capped(add_vel: Vector2, cap: float) -> void:
	# Normalising a zero vector will result in unexpected behavior.
	if add_vel.is_zero_approx():
		return

	var target_vel = vel + add_vel
	var para_dir = add_vel.normalized()
	var perp_dir = para_dir.orthogonal()

	var para = vel.dot(para_dir)

	var para_capped = para
	if para < cap:
		para_capped = min(para + add_vel.length(), cap)

	var para_vec = para_capped * para_dir

	var perp = target_vel.dot(perp_dir)
	var perp_vec = perp_dir * perp

	vel = para_vec + perp_vec


## Accelerate by a given velocity.
func accel(add_vel: Vector2) -> void:
	vel += add_vel


## Decelerate on a given axis by the given amount.
func decel(friction_amount: float, axis: Vector2 = x):
	# Sign of `axis` doesn't matter - it should cancel out.
	var remaining_mag = vel.dot(axis)
	var force = axis * clamp(remaining_mag, -friction_amount, friction_amount)
	vel -= force


## Set the velocity to an absolute vector.
func set_vel(value: Vector2) -> void:
	vel = value


## Set a component of the velocity in a given axis to a given value.
func set_vel_component(value: float, axis: Vector2) -> void:
	var axis_perp = axis.orthogonal()

	var perp = vel.dot(axis_perp)

	vel = (axis * value) + (axis_perp * perp)


## Return the component of velocity along a given axis.
func get_vel_component(axis: Vector2) -> float:
	return vel.dot(axis)


## Return 1 if the actor is moving to the right, -1 if left, and 0 if not moving.
func get_axis_direction(axis: Vector2) -> int:
	return sign(get_vel_component(axis))


## Return true if the actor is not moving in the X axis.
func is_moving_axis(axis: Vector2) -> bool:
	return !is_zero_approx(get_vel_component(axis))


## Return the direction vector of the velocity vector.
func get_direction() -> Vector2:
	return vel.normalized()
