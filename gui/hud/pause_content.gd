extends Control

onready var info = $Content/LevelInfo
onready var map = $Content/MapMenu
onready var fludd = $Content/FluddMenu
onready var options = $Content/OptionsMenu
onready var exit = $Content/ExitMenu
onready var button_map = $ButtonContainer/ButtonMap
onready var button_fludd = $ButtonContainer/ButtonFludd
onready var button_options = $ButtonContainer/ButtonOptions
onready var button_exit = $ButtonContainer/ButtonExit
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
	var info_visible: bool = true
	
	# Show whichever screen's button is pressed
	# (The script for the buttons guarantees only one can be pressed at a time)
	for i in range(4):
		if buttons[i].pressed and modulate.a > 0:
			menus[i].visible = true
			info_visible = false
		else:
			menus[i].visible = false
	
	# If no button is pressed, show the info screen
	# Control nodes don't like to be made invisible then visible in one frame, it messes with input
	info.visible = info_visible


func resize():
	button_map.resize()
	button_fludd.resize()
	button_options.resize()
	button_exit.resize()
