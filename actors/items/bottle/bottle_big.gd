extends Node2D

func _on_BottleBig_body_entered(_body):
	if Singleton.water < 100:
		Singleton.water = min(Singleton.water + 50, 100)
		queue_free()
