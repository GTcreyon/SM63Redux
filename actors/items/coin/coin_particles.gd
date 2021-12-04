extends Particles2D

var time = 0

func _ready():
	emitting = true


func _process(_delta):
	time += 1
	if time > 30:
		queue_free()
