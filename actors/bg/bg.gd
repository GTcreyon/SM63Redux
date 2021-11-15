extends CanvasLayer

func _process(_delta):
	var cam_pos = $"/root/Main/Player/Camera2D".get_camera_position()
	if OS.window_size.x > 448:
		$Sky.offset = Vector2.ZERO
		$Sky.scale = Vector2.ONE / 2
	else:
		$Sky.offset = Vector2(-224, -152)
		$Sky.scale = Vector2.ONE
	
	#$Layer2.texture_offset.x = -get_viewport().canvas_transform.get_origin().x / 5
	#$Sky.position.y = - $"/root/Main/Player".position.y / 20
	$Layer1.texture_offset.x = cam_pos.x / 10
	$Layer1.position.y = max(211, 211 - cam_pos.y / 20)
	$Layer2.texture_offset.x = cam_pos.x / 20
	$Layer2.position.y = -70 -cam_pos.y / 50
	$Layer3.texture_offset.x = cam_pos.x / 10
	$Layer3.position.y = lerp($Layer3.position.y, max(76, 76 -cam_pos.y / 5), 0.05)
	scale = Vector2.ONE * OS.window_size.x / 448
