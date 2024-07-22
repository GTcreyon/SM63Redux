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
# -	_hurt_crush():
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


func _ready():
	super()
	_setup_pickup_ids()
	_init_animation()


func _physics_step():
	super._physics_step()
	
	# Triggered when landing on the floor after being struck by a spin
	if is_on_floor() and struck and !stomped and vel.y > 0:
		# Play the landing sound, if there is one
		if sfx_struck_landed != null:
			if residualize_sfx_struck_landed:
				ResidualSFX.new_from_existing(sfx_struck_landed, get_parent())
			else:
				sfx_struck_landed.play()
		_struck_land()


func take_hit(type: Hitbox.Type, handler: HitHandler) -> bool:
	if disabled:
		return false

	# Default hurt behavior. Can be overridden.
	match type:
		Hitbox.Type.CRUSH, Hitbox.Type.CRUSH_HEAVY:
			if stomped:
				return false
			# Play the stomp sound, if there is one
			if sfx_stomp != null:
				if residualize_sfx_stomp:
					ResidualSFX.new_from_existing(sfx_stomp, get_parent())
				else:
					sfx_stomp.play()
			_hurt_crush(handler)
			return true
		Hitbox.Type.STRIKE:
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
	super.set_disabled(val)
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


func _hurt_crush(_handler: HitHandler):
	pass


## Pop the enemy up into the air and off to the side, away from the body that issued the strike
func _hurt_strike(handler: HitHandler):
	struck = true
	vel.y -= 2.63
	vel.x = max((12 + abs(vel.x) / 1.5), 0) * 5.4 * sign(position.x - handler.get_pos().x) / 10 / 1.5


func _struck_land():
	pass
