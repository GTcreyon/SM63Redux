extends GenericParticles2D


func _ready():
	g_emitting = true


func _process(_delta):
	if !g_emitting:
		queue_free()
