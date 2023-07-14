extends Node

@onready var window = get_window()


func _process(_delta):
	if Input.is_action_just_pressed("fullscreen") and OS.get_name() != "HTML5":
		if window.mode != Window.MODE_EXCLUSIVE_FULLSCREEN and window.mode != Window.MODE_FULLSCREEN:
			window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
		else:
			window.mode = Window.MODE_WINDOWED
	
	if Input.is_action_just_pressed("screen+") \
		and window.size.x + Singleton.DEFAULT_SIZE.x < DisplayServer.screen_get_size().x \
		and window.size.y + Singleton.DEFAULT_SIZE.y < DisplayServer.screen_get_size().y:
		window.size.x += Singleton.DEFAULT_SIZE.x
		window.size.y += Singleton.DEFAULT_SIZE.y
	if Input.is_action_just_pressed("screen-") \
		and window.size.x - Singleton.DEFAULT_SIZE.x >= Singleton.DEFAULT_SIZE.x:
		window.size.x -= Singleton.DEFAULT_SIZE.x
		window.size.y -= Singleton.DEFAULT_SIZE.y
