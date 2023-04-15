extends AnimatedSprite

func _ready():
	playing = true


func _on_SmokePoof_animation_finished():
	queue_free()
