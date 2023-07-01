class_name EntityEnemy
extends EntityMirrorable
# Parent class for enemy entities.
# Enemies are able to hurt the player with a hitbox, and be hurt/killed with a hurtbox.
# Enemies can drop a specified number of coins when killed.
# 
# Functions which child classes SHOULD implement:
# - _physics_step():
#		the update function, of course.
#		The default behavior handles landing from a spin/dive strike, then calls
#		 _hurtbox_check() if inside_check is set.
# -	_hurt_stomp():
# 		called when the enemy is stomped.
#		The default behavior is just to play sfx_stomp, if it exists.
# - _hurt_strike():
# 		called when the enemy is struck, e.g. by the player's spin or dive.
#		The default behavior is to play sfx_struck, if it exists, mark the
#		enemy as having been struck (struck = true), then pop the enemy a bit
#		upwards and to the side (away from the source of impact) by setting
#		velocity.
#		Generally _struck_land() handles the actual enemy death.
# -	_struck_land():
# 		called when the enemy lands after being struck.
#		The default behavior is just to play sfx_struck_landed, if it exists.

# Functions which child classes MAY implement:
# - _strike_check(body) -> bool:
#	checks if a given body should start a new strike.
#	A body passed to this function is guaranteed to be intersecting the enemy.
#	TODO: This function currently checks two things, whether the enemy CAN BE
#	struck and whether it IS BEING struck. For extensibility, these should
#	be two separate functions.

# Functions for child classes to use IN their implementations:
# - enemy_die():
#	destroys the enemy and spawns its coin pickups.

const COIN_PREFAB = preload("res://classes/pickup/coin/yellow/coin_yellow.tscn")
const SMOKE_PREFAB = preload("res://classes/entity/enemy/smoke_poof.tscn")

@export var coin_count: int = 1
@export var inside_check: bool = true
@export var multi_stomp: bool = false
# When true, produce a poof of smoke on death.
@export var death_smoke: bool = true
var dead: bool = false
var stomped: bool = false
var struck: bool = false
var _pickup_ids: Array = []

@export var _hurtbox_stomp_path: NodePath = "HurtboxStomp"
@onready var hurtbox_stomp = get_node_or_null(_hurtbox_stomp_path)

@export var _hurtbox_strike_path: NodePath = "HurtboxStrike"
@onready var hurtbox_strike = get_node_or_null(_hurtbox_strike_path)

@export var _hitbox_path: NodePath = "Hitbox"
@onready var hitbox = get_node_or_null(_hitbox_path)

# Optional death sound effects
@export var _sfx_stomp_path: NodePath = "SFXStomped"
@onready var sfx_stomp: AudioStreamPlayer2D = get_node_or_null(_sfx_stomp_path)

@export var _sfx_struck_path: NodePath = "SFXStruck"
@onready var sfx_struck: AudioStreamPlayer2D = get_node_or_null(_sfx_struck_path)

@export var _sfx_struck_land_path: NodePath = "SFXStruckLanded"
@onready var sfx_struck_landed: AudioStreamPlayer2D = get_node_or_null(_sfx_struck_land_path)

# Make the enemy die and drop its coins.
func enemy_die():
	for _i in range(coin_count):
		var id = _pickup_ids[_i]
		if !FlagServer.get_flag_state(id):
			var spawn = COIN_PREFAB.instantiate()
			spawn.get_pickup_node().assign_pickup_id(id)
			spawn.position = position
			spawn.dropped = true
			spawn.pop_velocity()
			get_parent().add_child(spawn)
	var spawn = SMOKE_PREFAB.instantiate()
	spawn.position = position
	get_parent().add_child(spawn)
	queue_free()


func _ready_override():
	super._ready_override()
	_setup_pickup_ids()
	_init_animation()


func _physics_step():
	super._physics_step()
	
	# Triggered when landing on the floor after being struck by a spin
	if is_on_floor() and struck and !stomped and vel.y > 0:
		_struck_land()
	
	if inside_check:
		_hurtbox_check()
	
	_hitbox_check()


# Reference to the player's body. Set from on_Hitbox_body_entered/on_Hitbox_body_exited
var player_body

# Damages the player if player_body isn't null
func _hitbox_check():
	if player_body and !struck and !stomped:
		player_body.take_damage_shove(1, sign(player_body.position.x - position.x))


func _hurtbox_check():
	if hurtbox_strike != null:
		for body in hurtbox_strike.get_overlapping_bodies():
			if _strike_check(body):
				_hurt_struck(body)


func _connect_signals():
	super._connect_signals()
	_connect_node_signal_if_exists(hurtbox_stomp, "area_entered", self, "_on_HurtboxStomp_area_entered")
	_connect_node_signal_if_exists(hurtbox_strike, "body_entered", self, "_on_HurtboxStrike_body_entered")
	_connect_node_signal_if_exists(hitbox, "body_entered", self, "_on_Hitbox_body_entered")
	_connect_node_signal_if_exists(hitbox, "body_exited", self, "_on_Hitbox_body_exited")


func set_disabled(val):
	super.set_disabled(val)
	_set_node_property_if_exists(hurtbox_stomp, "monitoring", !val)
	_set_node_property_if_exists(hurtbox_strike, "monitoring", !val)
	_set_node_property_if_exists(hitbox, "monitoring", !val)
	_set_node_property_if_exists(sprite, "playing", !val)


func _preempt_all_node_readies():
	super._preempt_all_node_readies()
	hurtbox_stomp = _preempt_node_ready(hurtbox_stomp, _hurtbox_stomp_path)
	hurtbox_strike = _preempt_node_ready(hurtbox_strike, _hurtbox_strike_path)
	hitbox = _preempt_node_ready(hitbox, _hitbox_path)
	sprite = _preempt_node_ready(sprite, _sprite_path)


# Get IDs from the collect server for each coin
func _setup_pickup_ids():
	_pickup_ids = FlagServer.claim_flag_id_array(coin_count)


# Start the sprite's animation and pseudorandomize its start point depending on position in the level
func _init_animation():
	if sprite != null and sprite is AnimatedSprite2D:
		if !disabled:
			sprite.frame = hash(position.x + position.y * PI) % sprite.frames.get_frame_count(sprite.animation)
			sprite.play()
		else:
			sprite.stop()


func _on_HurtboxStomp_area_entered(area):
	if !stomped or multi_stomp:
		_hurt_stomp(area)


func _on_HurtboxStrike_body_entered(body):
	if _strike_check(body):
		_hurt_struck(body)


func _on_Hitbox_body_entered(body):
	player_body = body # Assign to colliding body
	_hitbox_check() # Attempt to damage the player immediately


func _on_Hitbox_body_exited(_body):
	player_body = null # Unassign player body reference


# Check if the colliding body can strike this enemy
func _strike_check(body):
	return !struck and !stomped and (body.is_spinning() or (body.is_diving(true) and abs(body.vel.x) > 1))


func _hurt_stomp(_area):
	# Play the stomp sound, if there is one
	if sfx_stomp != null:
		ResidualSFX.new_from_existing(sfx_stomp, get_parent())
	
	pass


# Pop the enemy up into the air and off to the side, away from the body that issued the strike
func _hurt_struck(body):
	# Play the struck sound, if there is one
	if sfx_struck != null:
		sfx_struck.play()
	
	struck = true
	vel.y -= 2.63
	vel.x = max((12 + abs(vel.x) / 1.5), 0) * 5.4 * sign(position.x - body.position.x) / 10 / 1.5


func _struck_land():
	# Play the landing sound, if there is one
	if sfx_struck_landed != null:
		ResidualSFX.new_from_existing(sfx_struck_landed, get_parent())
	
	pass
