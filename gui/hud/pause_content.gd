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
	# Control nodes don't like to be made invisible then visible in one frame, it messes with input
	
	# Show whichever screen's button is pressed
	# (The script for the buttons guarantees only one can be pressed at a time)
	map.visible = map_button.pressed
	fludd.visible = fludd_button.pressed
	options.visible = options_button.pressed
	exit.visible = exit_button.pressed
	# If no button is pressed, show the info screen
	info.visible = !map.visible and !fludd.visible and !options.visible and !exit.visible
	
	# Show in-game stats if unpaused OR on the info screen
	for node in stats:
		node.visible = !Singleton.pause_menu or info.visible


func resize(scale):
	rect_scale = Vector2.ONE * scale
	margin_left = 37 * scale
	margin_right = -37 * scale - (OS.window_size.x / scale - 74) * (scale - 1)
	margin_top = 19 * scale
	margin_bottom = -33 * scale - (OS.window_size.y / scale - 52) * (scale - 1)
	info.resize(scale)
	map.resize(scale)
	# TODO: Presumably the FLUDD and Exit screens will need resizing eventually
	# (maybe not Options though?)
