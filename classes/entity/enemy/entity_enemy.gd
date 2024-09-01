class_name EntityEnemy
extends EntityMirrorable
## Abstract class for enemy entities.
##
## Enemies are able to hurt the player with a hitbox, and be hurt/killed with a hurtbox.
## Enemies can drop a specified number of coins when killed.

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

# Optional death sound effects
@export var _sfx_stomp_path: NodePath = "SFXStomped"
@onready var sfx_stomp: AudioStreamPlayer2D = get_node_or_null(_sfx_stomp_path)
@export var residualize_sfx_stomp = true

@export var _sfx_struck_path: NodePath = "SFXStruck"
@onready var sfx_struck: AudioStreamPlayer2D = get_node_or_null(_sfx_struck_path)
@export var residualize_sfx_struck = false

@export var _sfx_struck_land_path: NodePath = "SFXStruckLanded"
@onready var sfx_struck_landed: AudioStreamPlayer2D = get_node_or_null(_sfx_struck_land_path)
@export var residualize_sfx_struck_landed = true


## Make the enemy die and drop its coins.
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


func _ready():
	super()
	_setup_pickup_ids()
	_init_animation()


func _physics_step():
	super()
	
	# Triggered when landing on the floor after being struck
	if is_on_floor() and struck and !stomped and vel.y > 0:
		# Play the landing sound, if there is one
		if sfx_struck_landed != null:
			if residualize_sfx_struck_landed:
				ResidualSFX.new_from_existing(sfx_struck_landed, get_parent())
			else:
				sfx_struck_landed.play()
		_struck_land()


func take_hit(hit: Hit) -> bool:
	var type = hit.type
	var handler = hit.source
	if disabled:
		return false

	# Default hurt behavior. Can be overridden.
	match type:
		Hit.Type.STOMP, Hit.Type.POUND:
			if stomped:
				return false
			# Play the stomp sound, if there is one
			if sfx_stomp != null:
				if residualize_sfx_stomp:
					ResidualSFX.new_from_existing(sfx_stomp, get_parent())
				else:
					sfx_stomp.play()
			var pound := false
			if type == Hit.Type.POUND:
				pound = true
			_hurt_crush(handler, pound)
			return true
		Hit.Type.STRIKE:
			if struck:
				return false
			# Play the struck sound, if there is one
			if sfx_struck != null:
				if residualize_sfx_struck:
					ResidualSFX.new_from_existing(sfx_struck, get_parent())
				else:
					sfx_struck.play()
			_hurt_strike(handler)
			return true
		_:
			return false


func set_disabled(val):
	super(val)
	_set_node_property_if_exists(sprite, "playing", !val)


# Get IDs from the collect server for each coin
func _setup_pickup_ids():
	_pickup_ids = FlagServer.claim_flag_id_array(coin_count)


# Start the sprite's animation and pseudorandomize its start point depending on position in the level
func _init_animation():
	if sprite != null and sprite is AnimatedSprite2D:
		if !disabled:
			sprite.frame = hash(position.x + position.y * PI) % sprite.sprite_frames.get_frame_count(sprite.animation)
			sprite.play()
		else:
			sprite.stop()


## Called when the enemy is stomped or pounded.
func _hurt_crush(_handler: HitHandler, _pound: bool):
	pass


## Called when the enemy is struck.
## Default behavior is to pop the enemy up into the air and off to the side, away from the attacker.
func _hurt_strike(handler: HitHandler):
	struck = true
	vel.y -= 2.63
	vel.x = max((12 + abs(vel.x) / 1.5), 0) * 5.4 * sign(position.x - handler.get_pos().x) / 10 / 1.5


## Called when the enemy lands after being struck.
func _struck_land():
	pass
