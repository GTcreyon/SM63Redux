class_name CoinPickupRed
extends CoinPickup


func _award_pickup() -> void:
	_add_coins(2)
	Singleton.red_coin_total += 1
