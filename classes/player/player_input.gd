class_name PlayerInput
extends Node
## Abstract management of player input.
## Should be placed high up in the scene tree so that inputs are processed before they are checked.

## Duration in frames that the input buffer should last for.
const BUFFER_DURATION: int = 6

## If true, the player must continue holding an input for the buffer to apply.
const HOLD_TO_BUFFER: bool = false

## Remaining frames of input buffer for an action. Entries must be defined in _buffer_cache.
var _buffers: Dictionary = {}

## The last direction on the X axis pressed by the player.
var _last_x: int = 1

## Queue of inputs to have their buffer consumed.
var _consume_queue: Array[StringName] = []


func _ready():
	# Register all buffers in the input map.
	for id in InputMap.get_actions():
		_register_buffer(id)


func _physics_process(_delta):
	_update_last_x()
	_burn_buffers()
	_spark_buffers()
	_consume_buffers()


## Returns a float from -1 to 1 indicating the value of the horizontal input axis.
static func get_x() -> float:
	return Input.get_axis(&"left", &"right")


## Get the direction (sign) of the horizontal input axis.
static func get_x_dir() -> int:
	return sign(get_x())


## Returns true if the player is trying to move in the X axis.
static func is_moving_x() -> bool:
	return get_x() != 0


## Get the input direction vector.
static func get_vec() -> Vector2:
	return Input.get_vector(&"left", &"right", &"up", &"down")


## Return the last horizontal direction pressed.
func get_last_x() -> int:
	return _last_x


## Queue an input to have its buffer consumed.
func queue_consume(id: StringName) -> void:
	_consume_queue.append(id)


## Return true if an input is pressed or buffered.
func buffered_input(id: StringName, consume: bool = true) -> bool:
	if _buffers[id] > 0:
		if consume:
			queue_consume(id)
		return true

	if Input.is_action_just_pressed(id):
		# If the scene tree is configured correctly, this should not run.
		# The buffer should have been sparked before this function was called.
		# However, if the InputManager node has insufficient priority, this might not be the case.
		# This should be a warning, since it will mostly work as intended, but might be off by 1 frame.
		push_warning("Input pressed before buffer sparked. Does InputManager have sufficient priority?")
		return true

	return false


## Register a buffer of the given input action.
func _register_buffer(id: StringName) -> void:
	_buffers[id] = 0


## Update the _last_x variable.
func _update_last_x() -> void:
	var x = PlayerInput.get_x_dir()
	if x != 0:
		_last_x = x


## Tick down each buffer timer.
func _burn_buffers() -> void:
	for id in _buffers:
		# Cancel the buffer if HOLD_TO_BUFFER is on and the player is not holding an input.
		if HOLD_TO_BUFFER and not Input.is_action_pressed(id):
			_buffers[id] = 0
			continue

		var val = _buffers[id]

		if _buffers[id] > 0:
			_buffers[id] -= 1


## Iterate through all buffers, and begin any that have their action pressed.
func _spark_buffers() -> void:
	for id in _buffers:
		if Input.is_action_just_pressed(id):
			_buffers[id] = BUFFER_DURATION


## Consume the buffers that have been queued to be consumed.
func _consume_buffers() -> void:
	for id in _consume_queue:
		_buffers[id] = 0
	_consume_queue.clear()
