extends Node

func _process(_delta):
	if Input.is_action_just_pressed("fullscreen") && OS.get_name() != "HTML5":
		OS.window_fullscreen = !OS.window_fullscreen
	if Input.is_action_just_pressed("screen+") && OS.window_size.x + Singleton.DEFAULT_SIZE.x < OS.get_screen_size().x && OS.window_size.y + Singleton.DEFAULT_SIZE.y < OS.get_screen_size().y:
		OS.window_size.x += Singleton.DEFAULT_SIZE.x
		OS.window_size.y += Singleton.DEFAULT_SIZE.y
	if Input.is_action_just_pressed("screen-") && OS.window_size.x - Singleton.DEFAULT_SIZE.x >= Singleton.DEFAULT_SIZE.x:
		OS.window_size.x -= Singleton.DEFAULT_SIZE.x
		OS.window_size.y -= Singleton.DEFAULT_SIZE.y
