class_name CoinPickupBlue
extends CoinPickup


func _award_pickup(_body) -> void:
	_add_coins(5, _body)
