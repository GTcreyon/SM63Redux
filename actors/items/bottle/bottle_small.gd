extends Node2D

onready var singleton = $"/root/Singleton"

func _on_BottleSmall_body_entered(_body):
	if !Engine.editor_hint:
		singleton.water = min(singleton.water + 15, 100)
		queue_free()
