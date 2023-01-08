extends Control

onready var info = $Content/LevelInfo
onready var map = $Content/MapMenu
onready var fludd = $Content/FluddMenu
onready var options = $Content/OptionsMenu
onready var exit = $Content/ExitMenu
onready var stats = get_tree().get_nodes_in_group("stats")
onready var button_map = $ButtonContainer/ButtonMap
onready var button_map_off = $ButtonContainer/ButtonMap/StarsOff
onready var button_map_on = $ButtonContainer/ButtonMap/StarsOn
onready var button_fludd = $ButtonContainer/ButtonFludd
onready var button_fludd_off = $ButtonContainer/ButtonFludd/StarsOff
onready var button_fludd_on = $ButtonContainer/ButtonFludd/StarsOn
onready var button_options = $ButtonContainer/ButtonOptions
onready var button_options_off = $ButtonContainer/ButtonOptions/StarsOff
onready var button_options_on = $ButtonContainer/ButtonOptions/StarsOn
onready var button_exit = $ButtonContainer/ButtonExit
onready var button_exit_off = $ButtonContainer/ButtonExit/StarsOff
onready var button_exit_on = $ButtonContainer/ButtonExit/StarsOn
onready var bg = $BG
onready var top = $Top
onready var left_corner_top = $LeftCornerTop
onready var left_corner_bottom = $LeftCornerBottom
onready var right_corner_top = $RightCornerTop
onready var right_corner_bottom = $RightCornerBottom
onready var left = $Left
onready var right = $Right

func _process(_delta):
	# Control nodes don't like to be made invisible then visible in one frame, it messes with input
	for node in stats:
		node.visible = !Singleton.pause_menu
	if button_map.pressed:
		map.visible = true
		fludd.visible = false
		options.visible = false
		exit.visible = false
		info.visible = false
	elif button_fludd.pressed:
		map.visible = false
		fludd.visible = true
		options.visible = false
		exit.visible = false
		info.visible = false
	elif button_options.pressed:
		map.visible = false
		fludd.visible = false
		options.visible = true
		exit.visible = false
		info.visible = false
	elif button_exit.pressed:
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
	#rect_scale = Vector2.ONE * scale
#	margin_left = 37 * scale
#	margin_right = -37 * scale - (OS.window_size.x / scale - 74) * (scale - 1)
#	margin_top = 19 * scale
#	margin_bottom = -33 * scale - (OS.window_size.y / scale - 52) * (scale - 1)
	
	#	button_map.rect_scale = Vector2.ONE * scale
	#button_map.rect_position.x = 29 * scale
	#button_map.rect_size.x = floor((OS.window_size.x - 61 * scale) / scale / 4)
	button_map_off.polygon[1].x = button_map.rect_size.x - 1
	button_map_off.polygon[2].x = button_map.rect_size.x - 1
	button_map_on.polygon = button_map_off.polygon

	#button_fludd.rect_scale = Vector2.ONE * scale
	#button_fludd.rect_position.x = button_map.rect_position.x + button_map.rect_size.x * scale - 1 * scale
	#button_fludd.rect_size.x = ceil((OS.window_size.x - 61 * scale) / scale / 4)
	button_fludd_off.polygon[1].x = button_fludd.rect_size.x - 1
	button_fludd_off.polygon[2].x = button_fludd.rect_size.x - 1
	button_fludd_on.polygon = button_fludd_off.polygon

#	button_options.rect_scale = Vector2.ONE * scale
#	button_options.rect_position.x = button_fludd.rect_position.x + button_fludd.rect_size.x * scale - 1 * scale
#	button_options.rect_size.x = floor((OS.window_size.x - 61 * scale) / scale / 4)
	button_options_off.polygon[1].x = button_options.rect_size.x - 1
	button_options_off.polygon[2].x = button_options.rect_size.x - 1
	button_options_on.polygon = button_options_off.polygon

#	button_exit.rect_scale = Vector2.ONE * scale
#	button_exit.rect_position.x = button_options.rect_position.x + button_options.rect_size.x * scale - 1 * scale
#	button_exit.rect_size.x = floor((OS.window_size.x - 61 * scale) / scale / 4)
	button_exit_off.polygon[1].x = button_exit.rect_size.x - 1
	button_exit_off.polygon[2].x = button_exit.rect_size.x - 1
	button_exit_on.polygon = button_exit_off.polygon
	
#	top.rect_scale = Vector2.ONE * scale
#	top.rect_size.x = topsize + offset + 19 * scale
#	top.rect_position.x = 29 * scale - offset * scale - 19 * scale
#	left_corner_top.rect_scale = Vector2.ONE * scale
#	left_corner_bottom.rect_scale = Vector2.ONE * scale
#	right_corner_top.rect_scale = Vector2.ONE * scale
#	right_corner_bottom.rect_scale = Vector2.ONE * scale
#	left.rect_scale = Vector2.ONE * scale
#	left.rect_position.y = 17 * scale
#	left.rect_size.y = OS.window_size.y / scale - 17 - 33
#	right.rect_scale = Vector2.ONE * scale
#	right.rect_position.y = 17 * scale
#	right.rect_size.y = OS.window_size.y / scale - 17 - 33
	
	info.resize(scale)
	map.resize(scale)
