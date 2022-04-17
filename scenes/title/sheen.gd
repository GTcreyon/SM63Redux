extends Polygon2D

var progress = 0

func _process(delta):
	progress += 0.01 * 60 * delta
	texture_offset = global_position / max(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1) + Vector2.RIGHT * sin(progress * PI/2) * 5
