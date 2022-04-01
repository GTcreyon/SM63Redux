extends TextureRect

func _process(_delta):
	var scale = get_parent().scale
	rect_scale = scale * Vector2.ONE
