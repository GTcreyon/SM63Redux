extends Camera2D

onready var tween = $Tween
var current_zoom = 1.0
var target_zoom = 1.0

func _process(_delta):
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	if Input.is_action_just_pressed("screen+") && OS.window_size.x + 448 <= OS.get_screen_size().x && OS.window_size.y + 304 <= OS.get_screen_size().y:
		OS.window_size.x += 448
		OS.window_size.y += 304
	if Input.is_action_just_pressed("screen-") && OS.window_size.x - 448 >= 448:
		OS.window_size.x -= 448
		OS.window_size.y -= 304
	#$GUI.set_size(log(floor(OS.window_size.x / 448)) / log(2) + 1)
	#$GUI.set_size(floor(OS.window_size.x / 448))
	$GUI.set_size(floor(log(floor(OS.window_size.x / 448)) / log(2) + 1), floor(OS.window_size.x / 448))
	var zoom_factor = 448/OS.window_size.x
	
	if Input.is_action_just_pressed("zoom+"):
		target_zoom /= 2
		tween.stop_all()
		tween.interpolate_property(self, "current_zoom", null, target_zoom, 0.5, tween.TRANS_EXPO, Tween.EASE_OUT, 0)
		tween.start()
	if Input.is_action_just_pressed("zoom-"):
		target_zoom *= 2
		tween.stop_all()
		tween.interpolate_property(self, "current_zoom", null, target_zoom, 0.5, tween.TRANS_EXPO, Tween.EASE_OUT, 0)
		tween.start()
	
	zoom = Vector2.ONE * zoom_factor * current_zoom
