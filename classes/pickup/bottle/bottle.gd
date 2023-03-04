class_name Bottle
extends Pickup


export var amount: int = 15


func _award_pickup(_body) -> void:
	if _body.water < 100:
		_body.water = min(_body.water + amount, 100)
		queue_free()


func set_disabled(value):
	disabled = value
	set_deferred("monitoring", !value)
