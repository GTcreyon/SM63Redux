class_name FluddPickup
extends Pickup


export(Singleton.n) var nozzle_award: int


func _award_pickup(body):
	Singleton.nozzle = nozzle_award
	Singleton.water = max(Singleton.water, 100)
	body.switch_anim(body.sprite.animation.replace("_fludd", ""))
	queue_free()
