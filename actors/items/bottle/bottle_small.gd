extends Node2D

func _on_BottleSmall_body_entered(_body):
	if Singleton.water < 100:
		Singleton.water = min(Singleton.water + 15, 100)
		queue_free()
