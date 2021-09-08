extends Camera2D

onready var tween = $Tween
var current_zoom = 1.0
var target_zoom = 1.0
var target_limit_left = -10000000
var target_limit_right = 10000000
var target_limit_top = -10000000
var target_limit_bottom = 10000000
var first_frame = true

func _ready():
	limit_left = -10000000
	limit_right = 10000000
	limit_top = -10000000
	limit_bottom = 10000000


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
	if first_frame:
		limit_left = target_limit_left
		limit_right = target_limit_right
		limit_top = target_limit_top
		limit_bottom = target_limit_bottom
		first_frame = false
	else:
		limit_left = lerp(limit_left, target_limit_left, 0.05)
		limit_right = lerp(limit_right, target_limit_right, 0.05)
		limit_top = lerp(limit_top, target_limit_top, 0.05)
		limit_bottom = lerp(limit_bottom, target_limit_bottom, 0.05)
