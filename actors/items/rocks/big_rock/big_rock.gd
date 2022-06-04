extends StaticBody2D

export var disabled = false setget set_disabled
export var mirror = false setget set_mirror


func set_disabled(val):
	disabled = val
	set_collision_layer_bit(0, 0 if val else 1)


func set_mirror(val):
	mirror = val
	$Sprite.flip_h = val
