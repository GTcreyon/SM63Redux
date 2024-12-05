extends ParallaxBackground


func _process(delta):
	var screen_scale := Singleton.get_screen_scale(1)
	scale = Vector2.ONE * screen_scale
	scroll_base_scale = Vector2.ONE / screen_scale
