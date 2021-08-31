extends Camera2D

onready var tween = $Tween
var current_zoom = 1.0
var target_zoom = 1.0

func _process(_delta):
	var zoom_factor = 448/OS.window_size.x
	if !get_tree().paused:
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
