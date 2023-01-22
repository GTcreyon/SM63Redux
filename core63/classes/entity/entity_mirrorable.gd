class_name EntityMirrorable
extends Entity
# Parent class for an entity that can have its visuals mirrored.

export var mirror: bool = false

func _process_override(_delta):
	._process_override(_delta)
	if sprite != null:
		sprite.flip_h = mirror
