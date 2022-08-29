class_name Bottle
extends Pickup


export var amount: int = 15


func _award_pickup(_body) -> void:
	if Singleton.water < 100:
		Singleton.water = min(Singleton.water + amount, 100)
		queue_free()


func set_disabled(value):
	disabled = value
	monitoring = !value
