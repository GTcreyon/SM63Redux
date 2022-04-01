extends Sprite

var progress = 0.5
var season_progress = 0

func _process(_delta):
	var scalar = get_parent().scale
	scale = scalar * Vector2.ONE
	progress += (1.0 / 60.0) / 10
	if progress >= 1.5:
		season_progress = (season_progress + 1) % 9
		progress = 0
	position.y = OS.window_size.y * (1 - progress)
	position.x = OS.window_size.x / 10 * -progress + OS.window_size.x / 10 * (8 - season_progress)
