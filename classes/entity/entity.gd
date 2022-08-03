class_name Entity
extends KinematicBody2D
# Root class for all entities that move in any way.
# Entities have the Entity collision layer bit enabled, so they can influence weights.
# They have water collision built-in.

const GRAVITY = 0.17
const TERM_VEL_AIR = 6
const TERM_VEL_WATER = 2

export var disabled = false setget set_disabled
var vel = Vector2.ZERO
var _water_bodies: int = 0

export var _water_check_path: NodePath = "WaterCheck"
onready var water_check = get_node_or_null(_water_check_path)

func _ready():
	_ready_override()


func _ready_override():
	_entity_ready()


func _entity_ready():
	_connect_entity_signals()


func _connect_entity_signals():
	water_check = _preempt_node_ready(water_check, _water_check_path)
	_connect_node_signal_if_exists(water_check, "area_entered", self, "_on_WaterCheck_area_entered")
	_connect_node_signal_if_exists(water_check, "area_exited", self, "_on_WaterCheck_area_exited")


func _process(delta):
	_process_override(delta)


func _physics_process(_delta):
	if !disabled:
		_physics_step()


func _process_override(_delta):
	pass


func _physics_step():
	_entity_physics_step()


func _entity_physics_step():
	if _water_bodies > 0:
		vel.y = min(vel.y + GRAVITY, TERM_VEL_WATER)
	else:
		vel.y = min(vel.y + GRAVITY, TERM_VEL_AIR)
	
	if is_on_floor():
		vel.y = min(vel.y, GRAVITY)
	
	var snap
	if is_on_floor() && vel.y >= 0:
		snap = Vector2(0, 4)
	else:
		snap = Vector2.ZERO
	
	# warning-ignore:RETURN_VALUE_DISCARDED
	move_and_slide_with_snap(vel * 60, snap, Vector2.UP, true)


func _on_WaterCheck_area_entered(_area):
	_water_bodies += 1


func _on_WaterCheck_area_exited(_area):
	_water_bodies -= 1


func _entity_disabled(val):
	disabled = val
	set_collision_layer_bit(0, 0 if val else 1)


func set_disabled(val):
	_entity_disabled(val)


func _preempt_node_ready(node, path: NodePath) -> Node:
	return get_node_or_null(path) if node == null else node


func _set_node_disable_if_exists(node: Node, disabled: bool) -> void:
	if node != null:
		node.enabled = !disabled


func _connect_node_signal_if_exists(node, signame: String, target, method: String) -> void:
	if node != null:
		node.connect(signame, target, method)
