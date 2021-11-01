extends Node2D

onready var singleton = $"/root/Singleton"

func _on_BottleBig_body_entered(_body):
	if !Engine.editor_hint:
		singleton.water = min(singleton.water + 50, 100)
		queue_free()
