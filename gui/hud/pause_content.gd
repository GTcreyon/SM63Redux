extends Control

onready var info = $Content/LevelInfo
onready var map = $Content/MapMenu
onready var fludd = $Content/FluddMenu
onready var options = $Content/OptionsMenu
onready var exit = $Content/ExitMenu
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
	var buttons = [button_map, button_fludd, button_options, button_exit]
	var menus = [map, fludd, options, exit]
	info.visible = true
	for i in range(4):
		if buttons[i].pressed and modulate.a > 0:
			menus[i].visible = true
			info.visible = false
		else:
			menus[i].visible = false


func resize(scale):
	button_map_off.polygon[1].x = button_map.rect_size.x - 1
	button_map_off.polygon[2].x = button_map.rect_size.x - 1
	button_map_on.polygon = button_map_off.polygon
	
	button_fludd_off.polygon[1].x = button_fludd.rect_size.x - 1
	button_fludd_off.polygon[2].x = button_fludd.rect_size.x - 1
	button_fludd_on.polygon = button_fludd_off.polygon
	
	button_options_off.polygon[1].x = button_options.rect_size.x - 1
	button_options_off.polygon[2].x = button_options.rect_size.x - 1
	button_options_on.polygon = button_options_off.polygon
	
	button_exit_off.polygon[1].x = button_exit.rect_size.x - 1
	button_exit_off.polygon[2].x = button_exit.rect_size.x - 1
	button_exit_on.polygon = button_exit_off.polygon
