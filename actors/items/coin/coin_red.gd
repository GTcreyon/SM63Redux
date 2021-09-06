extends "res://actors/items/coin/coin.gd"

onready var player = $"/root/Main/Player"

func _on_PickupArea_body_entered(_body):
	singleton.coin_total += 2
	singleton.red_coin_total += 1
	if(player.life_meter_counter < 8):
		player.internal_coin_counter += 2
	$SFX.play()
	$PickupArea.queue_free() #clears up the acting segments of the coin so only the SFX is left
	$Sprite.queue_free()
