extends AudioStreamPlayer

var played = false

func _process(_delta): #workaround to allow the music to play at the right time
	if !played:
		play()
		played = true
