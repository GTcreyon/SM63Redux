extends Node2D

onready var singleton = $"/root/Singleton"

func _on_BottleBig_body_entered(_body):
	if singleton.water < 100:
		singleton.water = min(singleton.water + 50, 100)
		queue_free()
