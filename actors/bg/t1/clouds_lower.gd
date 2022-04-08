extends TextureRect

onready var cam = $"/root/Main/Player/Camera2D"

func _process(_delta):
	rect_scale = Vector2.ONE * max(round(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1)
	rect_pivot_offset.y = 93 / 2
