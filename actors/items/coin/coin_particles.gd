extends CPUParticles2D

var time = 0

func _ready():
	emitting = true


func _process(delta):
	time += 1 * 60 * delta
	if time > 30:
		queue_free()
