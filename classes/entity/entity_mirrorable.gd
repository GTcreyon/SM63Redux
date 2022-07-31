class_name EntityMirrorable
extends Entity
# Root class for an entity that can have its visuals mirrored

export var mirror: bool = false
export var _sprite_path: NodePath = "AnimatedSprite"
onready var sprite = get_node_or_null(_sprite_path)


func _process(_delta):
	_manage_mirror()


func _manage_mirror():
	if sprite != null:
		sprite.flip_h = mirror
