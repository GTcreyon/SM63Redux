extends StaticBody2D

@onready var safety_net = $SafetyNet
@export var disabled = false: set = set_disabled


func set_disabled(val):
	disabled = val
	set_collision_layer_value(1, 0 if val else 1)
	if safety_net == null:
		safety_net = $SafetyNet
	safety_net.monitoring = !val
