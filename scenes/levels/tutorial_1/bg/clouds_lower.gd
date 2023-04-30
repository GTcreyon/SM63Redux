extends TextureRect


func _process(_delta):
	rect_scale = Vector2.ONE * Singleton.get_screen_scale(1)
	rect_pivot_offset.y = 93 / 2
