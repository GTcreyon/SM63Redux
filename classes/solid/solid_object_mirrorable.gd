class_name SolidObjectMirrorable
extends StaticBody2D
## A StaticBody2D which can be both disabled or mirrored in the level designer.

@export var disabled = false: set = set_disabled
@export var mirror = false: set = set_mirror


func set_disabled(val):
	disabled = val
	set_collision_layer_value(0, 0 if val else 1)


func set_mirror(val):
	mirror = val
	$Sprite2D.flip_h = val
