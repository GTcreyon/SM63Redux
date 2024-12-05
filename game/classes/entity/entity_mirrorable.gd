class_name EntityMirrorable
extends Entity
# Parent class for an entity that can have its visuals mirrored.

@export var mirror: bool = false

@export var _sprite_path: NodePath = "AnimatedSprite2D"
@onready var sprite = get_node_or_null(_sprite_path)


func _process_override(_delta):
	super._process_override(_delta)
	if sprite != null:
		sprite.flip_h = mirror
