extends TextureRect

onready var cam = $"/root/Main/Player/Camera2D"

func _process(_delta):
	var cam_pos = cam.get_camera_position()
	var size = texture.get_size().x
	margin_left = 0
	#margin_top = max(-150, -150 - cam_pos.y / 20) * rect_scale.x
	rect_scale = Vector2.ONE * max(round(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1)
	rect_pivot_offset.y = 93 / 2
