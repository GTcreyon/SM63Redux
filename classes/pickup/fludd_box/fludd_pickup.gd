class_name FluddPickup
extends Pickup


@export var nozzle_award: int # (Singleton.Nozzles)


func _award_pickup(body):
	body.current_nozzle = nozzle_award
	body.water = max(body.water, 100)
	queue_free()
