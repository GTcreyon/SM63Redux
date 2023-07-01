extends AnimatedSprite2D

func _ready():
	play()


func _on_SmokePoof_animation_finished():
	queue_free()
