class_name Character

extends Entity
#Container class for a player character. 
#This is for functions all characters must have along with their own custom functions.


var is_alive: bool

export(int) var max_health = 8
var health = max_health
var health_shards: int = 0

#all values here are the defaults for Mario
export var max_velocity = 216

export var max_aerial_velocity : Vector2 = Vector2(640, 640)# ===========================================================
export var acceleration : Vector2 = Vector2(16, 16)#		  | the reason Vector2 is used on these instead of float is |
export var aerial_acceleration : Vector2 = Vector2(16, 16)#	  | to allow for characters with, for example, high jumps   |
export var deceleration : Vector2 = Vector2(30, 30)#		  | but low maneuverability, like Luigi.                    |
export var aerial_deceleration : Vector2 = Vector2(8, 8)#	  ===========================================================
export var turning_boost : float = 120.0
export var aerial_turning_boost : float


var invulnerable: bool = false
var invulnerable_frames: int = 0

var jumping: bool = false
var current_jump: int = 0
var jump_reset_time: int = 20 # Number of frames the character preserves their jump state on the ground

var can_change_direction: bool = true # Whether or not the players facing direction can be changed by pressing the left or right keys, for example would be true during walking state and false during diving state

var voice: AudioStreamPlayer2D


# Move up and move down are at the end due to hardcoded input indices
# TODO: Add these back in as they're needed!
enum input_names {left, right, jump}#, dive, spin, gp, gpcancel, fludd, nozzles, crouch, interact, up, down}

# Inputs
# First parameter is "pressed",
# Second parameter is "just_pressed",
# And third parameter is the input name.
# TODO: Add analog stick support with get_action_strength()
export var inputs: Dictionary
export var controlled_locally = true
export var rotating_jump = false

var camera: Camera2D


func _ready():
	set_initial_values()
	init_character()



func set_initial_values() -> void: # Override this function in a child class to organize variable settings
	pass


func init_character() -> void: # Similar to set_initial_values, but for more than just variable settings
	for input in input_names.keys():
		inputs[str(input)] = [false, false]


func _entity_process(delta):
	print((friction * int(grounded)) + (aerial_friction * int(!grounded)))
	update_inputs()
	update_move_direction()
	_character_process(delta)
	if grounded and is_on_floor() and !jumping:
		velocity.y = 0
	if move_direction == 0:
		if velocity.x != 0:
			velocity.x -= (deceleration.x * friction) * sign(velocity.x)

	#This is faster I swear please don't hunt me down
	velocity.x += turning_boost * int(bool(facing_direction != last_facing_direction)) * move_direction
	velocity.x *= int(!bool(abs(velocity.x) < (min(deceleration.x, acceleration.x) * ((friction * int(grounded))) + (aerial_friction * int(!grounded))) && velocity.x != 0))
	velocity.x = sign(velocity.x) * clamp(abs(velocity.x), 0, max_velocity)

	move_and_slide_with_snap(velocity * (1 + delta), Vector2(0, 1), Vector2.UP)
	invulnerable = invulnerable_frames > 0
	if invulnerable:
		invulnerable_frames -= 1


func _character_process(_delta): # Use this instead of _physics_process in your child classes!!
	pass


func update_move_direction() -> bool: # Returns true if inputs for a single direction are pressed this frame
	move_direction = int(inputs["right"][0]) - int(inputs["left"][0])
	if move_direction != 0:
		last_facing_direction = facing_direction
		facing_direction = move_direction
	return move_direction != 0
	
	# How the code above works:
	# - All bools can also be represented as a 1 (true) or 0 (false)
	# - (1 - 1) = 0, (0 - 1) = -1, (1 - 0) = 1, (0 - 0) = 0
	# - Because moving left on the X axis requires subtracting from your position,
	#	and moving right requires adding, we can subtract the boolean value for the
	#	negative x axis (left key) from the positive x axis key (right key) to get
	#	our direction normal. It even cancels out when both keys are pressed!
	#
	# Credits to Nathan Lovato (GDQuest) for teaching me this one. He probably
	#	learned it from somewhere else too. ;) -PlugN'Play 

func get_input(input_id: int, is_just_pressed: bool) -> bool:
	return inputs[input_id][int(is_just_pressed)]


func get_active_inputs(just_pressed_only: bool = false) -> PoolStringArray: # Returns the names of all inputs pressed this frame
	var output: PoolStringArray
	for input in inputs.keys():
		if just_pressed_only and inputs[input][1] == true:
			output.append(input)
		elif !just_pressed_only and (inputs[input][0] == true or inputs[input][1] == true):
			output.append(input)
	return output


func update_inputs() -> void:
	if controlled_locally:
		var control_id := 0
		for input in inputs.keys():
			inputs[input][0] = Input.is_action_pressed(input + "_" + str(control_id))
			inputs[input][1] = Input.is_action_just_pressed(input + "_" + str(control_id))


var prev_is_grounded := false
func is_grounded() -> bool:
	var raycast_node := ground_check
	raycast_node.cast_to = Vector2(0, 24)
#	if !ground_collision_dive.disabled:
#		raycast_node = ground_check_dive
#		raycast_node.cast_to = Vector2(0, 7.5)
	
	var new_is_grounded := (raycast_node.is_colliding() and velocity.y >= 0)
	if !new_is_grounded and prev_is_grounded and velocity.y > 0:
		velocity.y = 0
	
	prev_is_grounded = new_is_grounded
	return prev_is_grounded


func get_class():
	return "Character"
