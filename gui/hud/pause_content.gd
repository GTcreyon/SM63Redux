extends Control

onready var info = $LevelInfo
onready var map = $MapMenu
onready var fludd = $FluddMenu
onready var options = $OptionsMenu
onready var exit = $ExitMenu
onready var stats = get_tree().get_nodes_in_group("stats")
onready var map_button = get_parent().get_node("ButtonMap")
onready var fludd_button = get_parent().get_node("ButtonFludd")
onready var options_button = get_parent().get_node("ButtonOptions")
onready var exit_button = get_parent().get_node("ButtonExit")

func _process(_delta):
	#control nodes don't like to be made invisible then visible in one frame, it messes with input
	for node in stats:
		node.visible = not Singleton.pause_menu
	if map_button.pressed:
		map.visible = true
		fludd.visible = false
		options.visible = false
		exit.visible = false
		info.visible = false
	elif fludd_button.pressed:
		map.visible = false
		fludd.visible = true
		options.visible = false
		exit.visible = false
		info.visible = false
	elif options_button.pressed:
		map.visible = false
		fludd.visible = false
		options.visible = true
		exit.visible = false
		info.visible = false
	elif exit_button.pressed:
		map.visible = false
		fludd.visible = false
		options.visible = false
		exit.visible = true
		info.visible = false
	else:
		map.visible = false
		fludd.visible = false
		options.visible = false
		exit.visible = false
		info.visible = true
		for node in stats:
			node.visible = true

func resize(scale):
	rect_scale = Vector2.ONE * scale
	margin_left = 37 * scale
	margin_right = -37 * scale - (OS.window_size.x / scale - 74) * (scale - 1)
	margin_top = 19 * scale
	margin_bottom = -33 * scale - (OS.window_size.y / scale - 52) * (scale - 1)
	info.resize(scale)
	map.resize(scale)
