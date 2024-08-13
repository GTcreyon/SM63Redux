class_name Bottle
extends Pickup

const PARTICLE_SCENE = preload("./bottle_particles.tscn")


@export var amount: int = 15


func _award_pickup(_body) -> void:
	if _body.water < 100:
		_body.water = min(_body.water + amount, 100)


func set_disabled(value):
	disabled = value
	# TODO: Why set_deferred? If no reason, we could remove this entire override.
	set_deferred("monitoring", !value)


func _pickup_effect():
	var inst = PARTICLE_SCENE.instantiate()
	inst.position = self.position
	get_parent().add_child(inst)
