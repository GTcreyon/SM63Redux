extends CanvasLayer

func _process(_delta):
	#$Layer2.texture_offset.x = -get_viewport().canvas_transform.get_origin().x / 5
	$Layer2.texture_offset.x = $"/root/Main/Player".position.x / 5
	$Layer2.texture_offset.y = - 211 + $"/root/Main/Player".position.y / 10
	scale = Vector2.ONE * OS.window_size.x / 448
