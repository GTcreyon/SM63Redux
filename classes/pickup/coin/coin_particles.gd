extends Particles2D

func _ready():
	emitting = true


func _process(delta):
	if not emitting:
		queue_free()
