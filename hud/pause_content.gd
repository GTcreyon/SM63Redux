extends Control

onready var info = $LevelInfo
onready var map = $MapMenu
onready var fludd = $FluddMenu
onready var options = $OptionsMenu
onready var exit = $ExitMenu

#func _process(delta):
#	print(rect_size)

func resize(scale):
	rect_scale = Vector2.ONE * scale
	margin_left = 37 * scale
	margin_right = -37 * scale - (OS.window_size.x / scale - 74) * (scale - 1)
	margin_top = 19 * scale
	margin_bottom = -33 * scale - (OS.window_size.y / scale - 52) * (scale - 1)
	info.resize(scale)
	map.resize(scale)
