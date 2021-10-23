extends "res://actors/items/coin/coin.gd"

onready var player = $"/root/Main/Player"

func _on_PickupArea_body_entered(_body):
	singleton.coin_total += 5
	if singleton.hp < 8:
		player.internal_coin_counter += 5
	$SFX.play()
	$PickupArea.queue_free() #clears up the acting segments of the coin so only the SFX is left
	$Sprite.queue_free()

