class_name CoinPickup
extends Pickup

## Texture for the particles. Should usually match the color of the
## main sprite.
@export var particle_texture: CompressedTexture2D

var dropped = false


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
