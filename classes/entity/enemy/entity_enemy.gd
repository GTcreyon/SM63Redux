class_name EntityEnemy
extends EntityMirrorable
# Root class for enemy entities.
# Enemies are able to hurt the player with a hitbox, and be hurt/killed with a hurtbox.
# Enemies can drop a specified number of coins when killed.

const coin = preload("res://classes/pickup/coin/yellow/coin_yellow.tscn")

export var coin_count: int = 1
var collect_id: int = -1
var dead: bool = false
var stomped: bool = false
var struck: bool = false

export var _hurtbox_stomp_path: NodePath = "HurtboxStomp"
onready var hurtbox_stomp = get_node_or_null(_hurtbox_stomp_path)

export var _hurtbox_strike_path: NodePath = "HurtboxStrike"
onready var hurtbox_strike = get_node_or_null(_hurtbox_strike_path)

export var _hitbox_path: NodePath = "Hitbox"
onready var hitbox = get_node_or_null(_hitbox_path)


func _ready_override():
	_entity_enemy_ready()


func _entity_enemy_ready():
	_setup_collect_id()
	_init_animation()
	_connect_entity_enemy_signals()


func _connect_entity_enemy_signals():
	_entity_enemy_readyup_nodes()
	if hurtbox_stomp != null:
		hurtbox_stomp.connect("area_entered", self, "_on_HurtboxStomp_area_entered")
	if hurtbox_strike != null:
		hurtbox_strike.connect("body_entered", self, "_on_HurtboxStrike_body_entered")
	if hitbox != null:
		hitbox.connect("body_entered", self, "_on_Hitbox_body_entered")


func set_disabled(val):
	_entity_disabled(val)
	_entity_enemy_disabled(val)


func _entity_enemy_readyup_nodes():
	if hurtbox_stomp == null:
		hurtbox_stomp = get_node_or_null(_hurtbox_stomp_path)
	if hurtbox_strike == null:
		hurtbox_strike = get_node_or_null(_hurtbox_strike_path)
	if hitbox == null:
		hitbox = get_node_or_null(_hitbox_path)
	if sprite == null:
		sprite = get_node_or_null(_sprite_path)


func _entity_enemy_disabled(val):
	_entity_enemy_readyup_nodes()
	hurtbox_stomp.monitoring = !val
	hurtbox_strike.monitoring = !val
	hitbox.monitoring = !val
	sprite.playing = !val


func _setup_collect_id():
	collect_id = Singleton.get_collect_id()


func _init_animation():
	if sprite != null && sprite.has_method("set_playing"):
		sprite.playing = !disabled
		if !disabled:
			sprite.frame = hash(position.x + position.y * PI) % sprite.frames.get_frame_count(sprite.animation)


func _on_HurtboxStomp_area_entered(area):
	if !stomped:
		stomped = true
		_hurt_stomp(area)


func _on_HurtboxStrike_body_entered(body):
	if !struck && _damage_check(body):
		struck = true
		_hurt_struck(body)


func _on_Hitbox_body_entered(body):
	if !struck && !stomped:
		body.take_damage_shove(1, sign(body.position.x - position.x))


func _damage_check(body):
	return body.is_spinning() || (body.is_diving(true) && abs(body.vel.x) > 1)


func _hurt_stomp(area):
	pass


func _hurt_struck(body):
	pass
