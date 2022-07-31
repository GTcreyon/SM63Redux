class_name EntityEnemy
extends EntityMirrorable
# Root class for enemy entities.
# Enemies are able to hurt the player with a hitbox, and be hurt/killed with a hurtbox.
# Enemies can drop a specified number of coins when killed.

const coin = preload("res://classes/pickup/coin/yellow/coin_yellow.tscn")

export var coin_count: int = 1
var dead: bool = false
var struck = false

export var _hurtbox_path: NodePath = "Hurtbox"
onready var hurtbox = get_node_or_null(_hurtbox_path)


func set_disabled(val):
	_entity_disabled(val)
	_entity_enemy_disabled(val)


func _entity_enemy_disabled(val):
	if hurtbox == null:
		hurtbox = get_node_or_null(_hurtbox_path)
	if sprite == null:
		sprite = get_node_or_null(_sprite_path)
	hurtbox.monitoring = !val
	sprite.playing = !val
