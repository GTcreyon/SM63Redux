class_name EntityMirrorable
extends Entity
# Parent class for an entity that can have its visuals mirrored.

export var mirror: bool = false

export var _sprite_path: NodePath = "AnimatedSprite"
onready var sprite = get_node_or_null(_sprite_path)


func _process(_delta):
	_entity_mirrorable_process()


func _entity_mirrorable_process():
	if sprite != null:
		sprite.flip_h = mirror


func _process_override(_delta):
	_entity_mirrorable_process()
