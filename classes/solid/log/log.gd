extends StaticBody2D

@export var disabled = false: set = set_disabled


func set_disabled(val):
	disabled = val
	set_collision_layer_value(1, 0 if val else 1)
