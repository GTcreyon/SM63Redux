class_name CoinPickupRed
extends CoinPickup


func _award_pickup(_body) -> void:
	_add_coins(2, _body)
	Singleton.red_coin_total += 1
