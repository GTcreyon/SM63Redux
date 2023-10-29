class_name CoinPickup
extends Pickup

const PARTICLE_SCENE = preload("./coin_particles.tscn")

# Texture file for the particle effect.
@export var particle_texture: CompressedTexture2D

var dropped = false
var vel: Vector2 = Vector2.INF
var yellow = 0
var red = 0
var water_bodies = 0


func _ready_override() -> void:
	super._ready_override()
	
	if vel == Vector2.INF:
		vel.x = (Singleton.rng.randf() * 4 - 2) * 0.53
		vel.y = -7 * 0.53


func _add_coins(num: int, player: PlayerCharacter) -> void:
	Singleton.coin_total += num
	if player.hp < 8:
		player.coins_toward_health += num


func _pickup_effect() -> void:
	Singleton.get_node("SFX/Coin").play()
	var inst = PARTICLE_SCENE.instantiate()
	inst.texture = particle_texture
	if parent_is_root:
		inst.position = get_parent().position
		get_parent().get_parent().add_child(inst)
	else:
		inst.position = position
		get_parent().add_child(inst)
