extends Sprite2D

var progress = 0.5
var season_progress = 0


func _process(delta):
	var dmod = 60 * delta
	var scalar = get_parent().scale_vec
	var window_size = Vector2(get_window().size) # convert to float vector - avoids int div warning
	scale = scalar * Vector2.ONE
	progress += (1.0 / 60.0) / 10 * dmod
	if progress >= 1.5:
		season_progress = (season_progress + 1) % 9
		progress = 0
	position.y = window_size.y * (1 - progress)
	position.x = window_size.x / 10 * -progress + window_size.x / 10 * (8 - season_progress)
