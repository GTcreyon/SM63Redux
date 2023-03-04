class_name FluddPickup
extends Pickup


export(Singleton.Nozzles) var nozzle_award: int


func _award_pickup(body):
	body.current_nozzle = nozzle_award
	body.water = max(body.water, 100)
	body.switch_anim(body.sprite.animation.replace("_fludd", ""))
	queue_free()
