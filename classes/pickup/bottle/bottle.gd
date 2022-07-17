class_name Bottle
extends Area2D

export var disabled = false setget set_disabled

var amount = 15

func _on_Area_body_entered(_body):
	if Singleton.water < 100:
		Singleton.water = min(Singleton.water + amount, 100)
		queue_free()


func set_disabled(value):
	disabled = value
	monitoring = !value
