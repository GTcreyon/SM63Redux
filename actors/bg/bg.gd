extends CanvasLayer

func _process(_delta):
	if OS.window_size.x > 448:
		$Sky.offset = Vector2.ZERO
		$Sky.scale = Vector2.ONE / 2
	else:
		$Sky.offset = Vector2(-224, -152)
		$Sky.scale = Vector2.ONE
	
	#$Layer2.texture_offset.x = -get_viewport().canvas_transform.get_origin().x / 5
	#$Sky.position.y = - $"/root/Main/Player".position.y / 20
	$Layer1.texture_offset.x = $"/root/Main/Player".position.x / 10
	$Layer1.position.y = max(211, 211 - $"/root/Main/Player".position.y / 20)
	$Layer2.texture_offset.x = $"/root/Main/Player".position.x / 20
	$Layer2.position.y = -70 -$"/root/Main/Player".position.y / 50
	$Layer3.texture_offset.x = $"/root/Main/Player".position.x / 10
	$Layer3.position.y = lerp($Layer3.position.y, max(76, 76 -$"/root/Main/Player".position.y / 5), 0.05)
	scale = Vector2.ONE * OS.window_size.x / 448
