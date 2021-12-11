extends AudioStreamPlayer

var sound : AudioStreamSample

func _ready():
	stream = sound
	play()

func _on_ResidualSFX_finished():
	queue_free()
