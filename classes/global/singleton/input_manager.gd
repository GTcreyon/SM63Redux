extends Node

func _process(_delta):
	if Input.is_action_just_pressed("fullscreen") and OS.get_name() != "HTML5":
		OS.window_fullscreen = not OS.window_fullscreen
	if Input.is_action_just_pressed("screen+") and OS.window_size.x + Singleton.DEFAULT_SIZE.x < OS.get_screen_size().x and OS.window_size.y + Singleton.DEFAULT_SIZE.y < OS.get_screen_size().y:
		OS.window_size.x += Singleton.DEFAULT_SIZE.x
		OS.window_size.y += Singleton.DEFAULT_SIZE.y
	if Input.is_action_just_pressed("screen-") and OS.window_size.x - Singleton.DEFAULT_SIZE.x >= Singleton.DEFAULT_SIZE.x:
		OS.window_size.x -= Singleton.DEFAULT_SIZE.x
		OS.window_size.y -= Singleton.DEFAULT_SIZE.y
