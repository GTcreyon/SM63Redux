extends Label

var frames = 0

func _process(delta):
	text = str(frames)
	frames += 1
