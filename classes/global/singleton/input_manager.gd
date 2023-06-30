extends Node


func _process(_delta):
	if Input.is_action_just_pressed("fullscreen") and OS.get_name() != "HTML5":
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
	if Input.is_action_just_pressed("screen+") and get_window().size.x + Singleton.DEFAULT_SIZE.x < DisplayServer.screen_get_size().x and get_window().size.y + Singleton.DEFAULT_SIZE.y < DisplayServer.screen_get_size().y:
		get_window().size.x += Singleton.DEFAULT_SIZE.x
		get_window().size.y += Singleton.DEFAULT_SIZE.y
	if Input.is_action_just_pressed("screen-") and get_window().size.x - Singleton.DEFAULT_SIZE.x >= Singleton.DEFAULT_SIZE.x:
		get_window().size.x -= Singleton.DEFAULT_SIZE.x
		get_window().size.y -= Singleton.DEFAULT_SIZE.y
