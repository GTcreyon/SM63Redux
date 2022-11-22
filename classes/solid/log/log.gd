extends StaticBody2D

export var disabled = false setget set_disabled


func set_disabled(val):
	disabled = val
	set_collision_layer_bit(0, 0 if val else 1)
