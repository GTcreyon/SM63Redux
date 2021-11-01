extends "res://actors/items/coin/coin.gd"

onready var player = $"/root/Main/Player"
var picked = false
var active_timer = 30

func _process(_delta):
	if !picked:
		if dropped:
			active_timer = max(active_timer - 1, 0)
			if active_timer == 0:
				$PickupArea.monitoring = true
		else:
			$PickupArea.monitoring = true


func _on_PickupArea_body_entered(_body):
	singleton.coin_total += 1
	if singleton.hp < 8:
		player.internal_coin_counter += 1
	
	picked = true
	$SFX.play()
	$PickupArea.queue_free() #clears up the acting segments of the coin so only the SFX is left
	$Sprite.queue_free()
