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


func enemy_die():
	if Singleton.request_coin(collect_id):
		for _i in range(coin_count):
			var spawn = coin.instance()
			spawn.position = position
			spawn.dropped = true
			get_parent().add_child(spawn)
	queue_free()


func _ready_override():
	_entity_enemy_ready()


func _physics_step():
	_entity_enemy_physics_step()


func _entity_enemy_physics_step():
	_entity_physics_step()
	
	if is_on_floor() && struck && !stomped && vel.y > 0:
		_struck_land()
	
	for body in hurtbox_strike.get_overlapping_bodies():
		if _damage_check(body):
			_hurt_struck(body)


func _struck_land():
	pass


func _entity_enemy_ready():
	_entity_ready()
	_setup_collect_id()
	_init_animation()
	_connect_entity_enemy_signals()


func _connect_entity_enemy_signals():
	_entity_enemy_readyup_nodes()
	_connect_node_signal_if_exists(hurtbox_stomp, "area_entered", self, "_on_HurtboxStomp_area_entered")
	_connect_node_signal_if_exists(hurtbox_strike, "body_entered", self, "_on_HurtboxStrike_body_entered")
	_connect_node_signal_if_exists(hitbox, "body_entered", self, "_on_Hitbox_body_entered")


func set_disabled(val):
	_entity_enemy_disabled(val)


func _entity_enemy_readyup_nodes():
	hurtbox_stomp = _preempt_node_ready(hurtbox_stomp, _hurtbox_stomp_path)
	hurtbox_strike = _preempt_node_ready(hurtbox_strike, _hurtbox_strike_path)
	hitbox = _preempt_node_ready(hitbox, _hitbox_path)
	sprite = _preempt_node_ready(sprite, _sprite_path)


func _entity_enemy_disabled(val):
	_entity_disabled(val)
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
	if _damage_check(body):
		_hurt_struck(body)


func _on_Hitbox_body_entered(body):
	if !struck && !stomped:
		body.take_damage_shove(1, sign(body.position.x - position.x))


func _damage_check(body):
	return !struck && (body.is_spinning() || (body.is_diving(true) && abs(body.vel.x) > 1))


func _hurt_stomp(area):
	pass


func _hurt_struck(body):
	_default_enemy_struck(body)


func _default_enemy_struck(body):
	struck = true
	vel.y -= 2.63
	vel.x = max((12 + abs(vel.x) / 1.5), 0) * 5.4 * sign(position.x - body.position.x) / 10 / 1.5
