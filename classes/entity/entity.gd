class_name Entity
extends CharacterBody2D
# Root class for entities that move in any way.
# Entities have the Entity collision layer bit enabled, so they can influence weights.
# They have water collision built-in.

# Constants for movement. These should not need to be changed.
# In situations where these are variable (e.g. Space), it could be best to use a multiplier.
const GRAVITY = 0.17
const TERM_VEL_AIR = 6
const TERM_VEL_WATER = 2

@export var disabled = false
var vel = Vector2.ZERO
var _water_bodies: int = 0

# Entities may or may not have certain functionality nodes.
# The WaterCheck node, for example, is used to determine if the entity is in water or not.
# However, this may not always be necessary. If an entity is unaffected by water, this node is obsolete.
# As such, we want an implementation in which nodes are optional, and the code handles this.
# For that, we use a private exported node path, that can be assigned in the scene editor.
# This is then loaded into the main variable on ready.
# If this returns null, we assume the node does not exist, and as such functionality is disabled.
@export var _water_check_path: NodePath = "WaterCheck"
@onready var water_check = get_node_or_null(_water_check_path)


func _ready():
	set_disabled(disabled)
	_connect_signals()


# Connect WaterCheck signals through code.
# Since this is in a parent class, this cannot be done in the scene editor.
func _connect_signals():
	_connect_node_signal_if_exists(water_check, "area_entered", self, "_on_WaterCheck_area_entered")
	_connect_node_signal_if_exists(water_check, "area_exited", self, "_on_WaterCheck_area_exited")


func _physics_process(_delta):
	if !disabled:
		_physics_step()


# The default entity physics step.
func _physics_step():
	if _water_bodies > 0:
		vel.y = min(vel.y + GRAVITY, TERM_VEL_WATER)
	else:
		vel.y = min(vel.y + GRAVITY, TERM_VEL_AIR)
	
	if is_on_floor():
		vel.y = min(vel.y, GRAVITY)
	
	var snap
	if is_on_floor() and vel.y >= 0:
		snap = 4
	else:
		snap = 0
	
	# warning-ignore:RETURN_VALUE_DISCARDED
	set_velocity(vel * 60)
	floor_snap_length = snap
	set_up_direction(Vector2.UP)
	set_floor_stop_on_slope_enabled(true)
	move_and_slide()


# WaterCheck signal methods.
func _on_WaterCheck_area_entered(_area):
	_water_bodies += 1


func _on_WaterCheck_area_exited(_area):
	_water_bodies -= 1


# Setget for the "disabled" property
# Can be overridden in child classes
func set_disabled(val):
	disabled = val
	set_collision_layer_value(3, 0 if val else 1)


# The following functions deal with child nodes that may or may not exist.
# This is useful for having optional functionality.

# Set a node's property if the node exists.
func _set_node_property_if_exists(node: Node, property: String, val) -> void:
	if node != null:
		node.set(property, val)


# Connect a node to a signal if the node exists.
func _connect_node_signal_if_exists(node, signame: String, target, method: String, deferred : bool = false) -> void:
	if node != null:
		node.connect(signame, Callable(target, method), CONNECT_DEFERRED if deferred else 0)
