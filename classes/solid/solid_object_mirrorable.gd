class_name SolidObjectMirrorable
extends SolidObject
## A StaticBody2D which can be both disabled or mirrored in the level designer.

@export var mirror = false: set = set_mirror


func set_mirror(val):
	mirror = val
	$Sprite2D.flip_h = val
