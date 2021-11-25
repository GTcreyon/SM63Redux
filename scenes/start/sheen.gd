extends Polygon2D

var progress = 0

func _process(_delta):
	progress += 0.01
	texture_offset = global_position / floor(OS.window_size.y / 304) + Vector2.RIGHT * sin(progress * PI/2) * 5
