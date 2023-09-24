extends TextureRect


func _process(_delta):
	scale = Vector2.ONE * Singleton.get_screen_scale(1)
	pivot_offset.y = 93.0 / 2
