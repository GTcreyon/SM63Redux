extends Polygon2D

var progress = 0


func _process(delta):
	progress += 0.01 * 60 * delta
	texture_offset = global_position / Singleton.get_screen_scale() + Vector2.RIGHT * sin(progress * PI/2) * 5
