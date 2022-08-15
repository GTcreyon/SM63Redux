class_name EntityEnemy
extends EntityMirrorable
# Parent class for enemy entities.
# Enemies are able to hurt the player with a hitbox, and be hurt/killed with a hurtbox.
# Enemies can drop a specified number of coins when killed.

const COIN_PREFAB = preload("res://classes/pickup/coin/yellow/coin_yellow.tscn")

export var coin_count: int = 1
export var inside_check: bool = true
export var multi_stomp: bool = false
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


# Make the enemy die and drop its coins.
func enemy_die():
	if Singleton.request_coin(collect_id):
		for _i in range(coin_count):
			var spawn = COIN_PREFAB.instance()
			spawn.position = position
			spawn.dropped = true
			get_parent().add_child(spawn)
	queue_free()


func _ready_override():
	._ready_override()
	_setup_collect_id()
	_init_animation()


func _physics_step():
	._physics_step()
	
	# Triggered when landing on the floor after being struck by a spin
	if is_on_floor() && struck && !stomped && vel.y > 0:
		_struck_land()
	
	if inside_check:
		_hurtbox_check()


func _hurtbox_check():
	if hurtbox_strike != null:
		for body in hurtbox_strike.get_overlapping_bodies():
			if _strike_check(body):
				_hurt_struck(body)


func _struck_land():
	pass


func _connect_signals():
	._connect_signals()
	_connect_node_signal_if_exists(hurtbox_stomp, "area_entered", self, "_on_HurtboxStomp_area_entered")
	_connect_node_signal_if_exists(hurtbox_strike, "body_entered", self, "_on_HurtboxStrike_body_entered")
	_connect_node_signal_if_exists(hitbox, "body_entered", self, "_on_Hitbox_body_entered")


func set_disabled(val):
	.set_disabled(val)
	_set_node_property_if_exists(hurtbox_stomp, "monitoring", !val)
	_set_node_property_if_exists(hurtbox_strike, "monitoring", !val)
	_set_node_property_if_exists(hitbox, "monitoring", !val)
	_set_node_property_if_exists(sprite, "playing", !val)


func _preempt_all_node_readies():
	._preempt_all_node_readies()
	hurtbox_stomp = _preempt_node_ready(hurtbox_stomp, _hurtbox_stomp_path)
	hurtbox_strike = _preempt_node_ready(hurtbox_strike, _hurtbox_strike_path)
	hitbox = _preempt_node_ready(hitbox, _hitbox_path)
	sprite = _preempt_node_ready(sprite, _sprite_path)


# Get a collect ID from the collect server
func _setup_collect_id():
	if coin_count > 0:
		collect_id = Singleton.get_collect_id()


# Start the sprite's animation and pseudorandomise its start point depending on position in the level
func _init_animation():
	if sprite != null and sprite.get("playing") != null:
		sprite.playing = !disabled
		if !disabled:
			sprite.frame = hash(position.x + position.y * PI) % sprite.frames.get_frame_count(sprite.animation)


func _on_HurtboxStomp_area_entered(area):
	if !stomped || multi_stomp:
		stomped = true
		_hurt_stomp(area)


func _on_HurtboxStrike_body_entered(body):
	if _strike_check(body):
		_hurt_struck(body)


func _on_Hitbox_body_entered(body):
	if !struck && !stomped:
		body.take_damage_shove(1, sign(body.position.x - position.x))


# Check if the colliding body can strike this enemy
func _strike_check(body):
	return !struck && (body.is_spinning() || (body.is_diving(true) && abs(body.vel.x) > 1))


func _hurt_stomp(area):
	pass


# Pop the enemy up into the air and off to the side, away from the body that issued the strike
func _hurt_struck(body):
	struck = true
	vel.y -= 2.63
	vel.x = max((12 + abs(vel.x) / 1.5), 0) * 5.4 * sign(position.x - body.position.x) / 10 / 1.5
