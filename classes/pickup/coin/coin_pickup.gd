class_name CoinPickup
extends Pickup

## Texture for the particles. Should usually match the color of the
## main sprite.
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


func _pickup_sound():
	Singleton.get_node("SFX/Coin").play()


func _pickup_effect() -> Node2D:
	# Change the instantiated particles' texture
	var inst = super()
	inst.texture = particle_texture
	return inst
