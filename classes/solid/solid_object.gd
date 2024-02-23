class_name SolidObject
extends StaticBody2D
## A StaticBody2D which can be disabled in the level designer.

@export var disabled = false: set = set_disabled


func set_disabled(val):
	disabled = val
	set_collision_layer_value(0, 0 if val else 1)
