class_name Motion
extends Node
## Handles movement of the actor.

## Time delay allowed before cancelling a double/triple jump.
const CONSEC_JUMP_TIME: int = 8
const COYOTE_TIME: int = 5
const RESIST_DECREMENT: float = 1.0 / 20.0

## Length of a timestep in the original SM63 compared to Redux (60fps/32fps).
## Use when porting code directly from the original. Do not use otherwise.
const LEGACY_DELTA: float = 1.875
const LEGACY_DELTA_INV: float = 0.533333
const LEGACY_DELTA_ISQ: float = LEGACY_DELTA_INV * LEGACY_DELTA_INV

## Target actor of this motion manager.
@export var actor: CharacterBody2D = owner
@export var gravity: float = 1
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

var _rotation: float = 0.0


func _ready():
	var v = 0
	var oldv = 0
	for i in 999:
		v += 1# * 32.0 / 60.0 * 32.0 / 60.0
		print(v)
		oldv = v
		#v = _resist(v, 0.2, 1.05, true)
		#v = _resist(v, 0, 1.001, true)
		v = _resist(v, 0.2, 1.051, false)
		print(v)
	print(oldv * 1.875)
	print(v * 1.875)


func _physics_process(delta):
	_move_actor(delta)
	resist = max(resist - RESIST_DECREMENT, 0)
	if active_consec_time():
		consec_jump_timer -= 1


## Set the player's rotation to the given value.
func set_rotation(value: float) -> void:
	_rotation = value
	actor.sprite.rotation = value


## Apply downward acceleration.
func apply_gravity(multiplier: float = 1.0, legacy: bool = false) -> void:
	var amount = gravity * multiplier
	if legacy:
		legacy_accel_y(amount, false)
	else:
		accel_y(amount)


## Activate the consecutive jump timer.
func activate_consec_timer() -> void:
	consec_jump_timer = CONSEC_JUMP_TIME


## Return whether the consecutive jump timer is or isn't running.
func active_consec_time() -> bool:
	return consec_jump_timer > 0


## Consume the consecutive jump timer, removing the chance for a consecutive jump.
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


## Accelerate on the X axis.
func accel_x(amount: float) -> void:
	accel(amount * Vector2.RIGHT)


## Accelerate on the Y axis.
func accel_y(amount: float) -> void:
	accel(amount * Vector2.DOWN)


## Accelerate on the X axis with a maximum speed.
func accel_x_capped(amount: float, cap: float) -> void:
	accel_capped(amount * Vector2.RIGHT, cap)


## Accelerate on the Y axis with a maximum speed.
func accel_y_capped(amount: float, cap: float) -> void:
	accel_capped(amount * Vector2.DOWN, cap)


## Accelerate on the X axis.
func legacy_accel_x(amount: float, impulse: bool = false) -> void:
	legacy_accel(amount * Vector2.RIGHT, impulse)


## Accelerate on the Y axis.
func legacy_accel_y(amount: float, impulse: bool = false) -> void:
	legacy_accel(amount * Vector2.DOWN, impulse)


## Apply legacy friction on the X axis.
func legacy_friction_x(sub: float, div: float) -> void:
	vel.x = _resist(vel.x, sub, div, true)


## Apply legacy friction on the Y axis.
func legacy_friction_y(sub: float, div: float) -> void:
	vel.y = _resist(vel.y, sub, div, true)


## Accelerate by a given velocity using the legacy system.
## Set `impulse` to `false` for acceleration over time (e.g. falling)
## Set `impulse` to `true` for instant acceleration (e.g. jumping)
func legacy_accel(add_vel: Vector2, impulse: bool = false) -> void:
	if impulse:
		add_vel *= LEGACY_DELTA_INV
	else:
		add_vel *= LEGACY_DELTA_ISQ
	accel(add_vel)


## Accelerate by a given velocity, up to a certain limit.
## If already above the limit due to external forces, this will not reduce speed.
func accel_capped(add_vel: Vector2, cap: float) -> void:
	# No need to move if we're not adding any velocity.
	# Also, normalising a zero vector will result in unexpected behavior.
	if add_vel.is_zero_approx():
		return

	# Calculate a vector parallel to the added velocity vector
	var para_dir = add_vel.normalized()

	# Calculate the current speed in the direction of acceleration
	var para = vel.dot(para_dir)

	# Calculate the amount of speed to add in the direction of acceleration.
	var para_add = add_vel.length()

	# Calculate how much speed we'd be allowed to add before getting capped.
	var cap_difference = cap - para

	# Cap off at that speed.
	para_add = min(para_add, cap_difference)
	
	# We don't want to decelerate, so break if less than zero.
	if para_add <= 0:
		return
	
	# Apply the speed in the correct direction.
	var para_add_vec = para_add * para_dir

	# Add the final vector.
	vel += para_add_vec


## Accelerate by a given velocity.
func accel(add_vel: Vector2) -> void:
	vel += add_vel


## Decelerate on a given axis by the given amount.
func decel(friction_amount: float, axis: Vector2 = x):
	# Sign of `axis` doesn't matter - it should cancel out.
	var remaining_mag = get_vel_component(axis)
	var force = axis * clamp(remaining_mag, -friction_amount, friction_amount)
	vel -= force


## Decelerate more at higher speeds.
func progressive_decel(low_friction: float, high_friction: float, low_speed: float, high_speed: float, axis: Vector2 = x):
	var prog = inverse_lerp(low_speed, high_speed, get_vel_component(axis))
	var prog_clamped = clamp(prog, 0, 1)
	var friction = lerp(low_friction, high_friction, prog_clamped)
	decel(friction, axis)


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


## Move the actor using the stored `vel` value.
func _move_actor(delta: float) -> void:
	# Ensure that we move a constant horizontal distance when going up slopes.
	# In the original you get slowed down by slopes. But this seems comfier.
	actor.floor_constant_speed = true

	actor.velocity = vel / delta
	actor.move_and_slide()
	vel = actor.velocity * delta


### Resistance function from OG SM63.
func _resist(val: float, sub: float, div: float, legacy: bool = false):
	var modsub
	if legacy:
		val *= LEGACY_DELTA
		modsub = sub * LEGACY_DELTA_INV
	else:
		modsub = sub
	
	val = move_toward(val, 0, modsub)
	if val == 0:
		return 0
		
	if legacy:
		val *= pow(div, -LEGACY_DELTA_INV)
		return val * LEGACY_DELTA_INV
	else:
		return val / div
