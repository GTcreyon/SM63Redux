class_name Telescoping
extends Node2D
# Root class for objects that can change lengths, such as clouds and tipping logs.

@export var _safety_net_path: NodePath = "SafetyNet"
@onready var safety_net = get_node_or_null(_safety_net_path)

@export var _collision_path: NodePath = "CollisionShape2D"
@onready var collision = get_node_or_null(_collision_path)

@export var _left_end_path: NodePath = "LeftEnd"
@onready var left_end = get_node_or_null(_left_end_path)

@export var _right_end_path: NodePath = "RightEnd"
@onready var right_end = get_node_or_null(_right_end_path)

@export var _middle_section_path: NodePath = "MiddleSection"
@onready var middle_section = get_node_or_null(_middle_section_path)

@export var disabled: bool = false: set = set_disabled
@export var width: int = 1: set = set_width
@export var middle_segment_width: int = 16
@export var end_segment_width: int = 8
@export var end_collision_width: int = 15


func set_width(new_width):
	ready_nodes()
	width = new_width
	if width <= 0:
		middle_section.visible = false
	else:
		middle_section.visible = true
	collision.shape.size.x = (middle_segment_width) * width + end_collision_width
	if safety_net != null:
		safety_net.get_child(0).shape.size.x = (middle_segment_width / 2.0) * width + end_collision_width
	middle_section.size.x = middle_segment_width * width
	middle_section.position.x = -(middle_segment_width / 2.0) * width
	
	left_end.position.x = -(middle_segment_width / 2.0) * width
	right_end.position.x = (middle_segment_width / 2.0) * width


func ready_nodes():
	safety_net = get_node_or_null(_safety_net_path)
	collision = get_node_or_null(_collision_path)
	left_end = get_node_or_null(_left_end_path)
	right_end = get_node_or_null(_right_end_path)
	middle_section = get_node_or_null(_middle_section_path)


func set_disabled(val):
	disabled = val
	
	if safety_net == null:
		safety_net = $SafetyNet
	safety_net.monitoring = !val
	
	var carrier_node = get_node(get_path())
	if carrier_node is StaticBody2D:
		carrier_node.set_collision_layer_value(0, 0 if val else 1)
	# Hack solution to allow inheriting in classes that aren't StaticBody2D
	# Hoping 4.0 will have a way to avoid this
	# If anyone knows a solution in the short-term, please speak up!
