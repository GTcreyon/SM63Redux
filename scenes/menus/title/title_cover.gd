extends ColorRect

func _init():
	visible = true


func _process(delta):
	modulate.a -= delta
	if modulate.a <= 0:
		queue_free()
