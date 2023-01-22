class_name Entity

extends KinematicBody2D
# Root class for entities that move in any way.
# Entities have the Entity collision layer bit enabled, so they can influence weights.
# They have water collision built-in.

var facing_direction: float = 1 #tracks the direction the character is facing. -2 = left, +1 = right.
var last_facing_direction: float = 1
var move_direction: float = 0 #determines the direction the character moves in. -1 = left, +1 = right, 0 = stationary

#TODO: It would probably be a good idea to allow analog sticks to gradually change the character's movement speed,
#as long as we can determine it wouldn't create a drastically unfair advantage against a keyboard.

var velocity: Vector2 = Vector2.ZERO
var weight: float = 7.82

#Unused for now. TODO: Revisit gravity fields
#var gravity_scale: float = 1.0
#var gravity_normal: Vector2 = Vector2(0, 1) #<-----==================================================
#var inside_gravity_override: bool = false#			| Direction of gravity. Avoid setting this;      |
#													| gravity overrides will set this automatically. |
#													==================================================

var inventory: CharacterInventory #inventory for the current character
var state_manager: StateManager #Entity may not need a StateManager, but this is here just in case
var sprite: AnimatedSprite

# Constants for movement. These should not need to be changed.
# In situations where these are variable (e.g. Space), it could be best to use a multiplier.
const GRAVITY = 0.17
const TERM_VEL_AIR = 6
const TERM_VEL_WATER = 2

var has_friction: bool = false

export var friction: float = 1
export var aerial_friction: float = 2

export var disabled = false setget set_disabled
var controllable: bool = true #controllable = should inputs be allowed to move the character?
var can_turn: bool = false

#TODO: Evaluate necessity.
var ground_check: RayCast2D #
var grounded: bool = false #is the character on the ground?

var _water_bodies: int = 0

# Entities may or may not have certain functionality nodes.
# The WaterCheck node, for example, is used to determine if the entity is in water or not.
# However, this may not always be necessary. If an entity is unaffected by water, this node is obsolete.
# As such, we want an implementation in which nodes are optional, and the code handles this.
# For that, we use a private exported node path, that can be assigned in the scene editor.
# This is then loaded into the main variable on ready.
# If this returns null, we assume the node does not exist, and as such functionality is disabled.
export var _water_check_path: NodePath = "WaterCheck"
onready var water_check = get_node_or_null(_water_check_path)


# Virtual methods such as _ready(), _process() and _physics_process() behave unusually when inherited.
# This (I think) is because Godot manages these with notifications, unlike other methods.
# As such, overriding them doesn't actually disable the original functionality.
# For this reason, we wrap the code in a separate function, which can be overridden properly.
# See _ready_override().
func _ready():
	_ready_override()


func _ready_override():
	_connect_signals()


# Connect WaterCheck signals through code.
# Since this is in a parent class, this cannot be done in the scene editor.
func _connect_signals():
	_preempt_all_node_readies()
	_connect_node_signal_if_exists(water_check, "area_entered", self, "_on_WaterCheck_area_entered")
	_connect_node_signal_if_exists(water_check, "area_exited", self, "_on_WaterCheck_area_exited")


func _preempt_all_node_readies():
	water_check = _preempt_node_ready(water_check, _water_check_path)


func _process(delta):
	_process_override(delta)


func _physics_process(_delta):
	if !disabled:
		_physics_step()


func _process_override(_delta):
	pass


# The default entity physics step.
func _physics_step():
	if _water_bodies > 0:
		velocity.y = min(velocity.y + GRAVITY, TERM_VEL_WATER)
	else:
		velocity.y = min(velocity.y + GRAVITY, TERM_VEL_AIR)
	
	if is_on_floor():
		velocity.y = min(velocity.y, GRAVITY)
	
	var snap
	if is_on_floor() and velocity.y >= 0:
		snap = Vector2(0, 4)
	else:
		snap = Vector2.ZERO
	
	# warning-ignore:RETURN_VALUE_DISCARDED
	move_and_slide_with_snap(velocity * 60, snap, Vector2.UP, true)


# WaterCheck signal methods.
func _on_WaterCheck_area_entered(_area):
	_water_bodies += 1


func _on_WaterCheck_area_exited(_area):
	_water_bodies -= 1


# Setget for the "disabled" property
# Can be overridden in child classes
func set_disabled(val):
	disabled = val
	_preempt_all_node_readies()
	set_collision_layer_bit(0, 0 if val else 1)


# The following functions deal with child nodes that may or may not exist.
# This is useful for having optional functionality.

# Almost functionally identical to simply running get_node_or_null(path).
# However, this function is used due to its semantic significance.
# It is also marginally more secure, as it will not destroy the reference if the node is reparented.
# This is used during the ready cycle, when a node may not be assigned to its variable properly.
func _preempt_node_ready(node, path: NodePath) -> Node:
	return get_node_or_null(path) if node == null else node


# Set a node's property if the node exists.
func _set_node_property_if_exists(node: Node, property: String, val) -> void:
	if node != null:
		node.set(property, val)


# Connect a node to a signal if the node exists.
func _connect_node_signal_if_exists(node, signame: String, target, method: String) -> void:
	if node != null:
		node.connect(signame, target, method)
