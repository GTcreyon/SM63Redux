extends Control

const SCROLL_SPEED = 16

onready var list = $List
onready var camera_fix = $List/CameraFix
onready var touch_controls = $List/TouchControls
onready var mute_music = $List/MuteMusic
onready var mute_sfx = $List/MuteSFX
onready var show_timer = $List/ShowTimer
onready var locale_select = $List/LocaleSelect
onready var button_menu = $List/ButtonMenu
onready var touch_menu = $List/TouchMenu
var bus_music = AudioServer.get_bus_index("Music")
var bus_sfx = AudioServer.get_bus_index("SFX")
var height_set = false
var start_height
var max_height
var was_visible = false


func _ready():
	_reset_values()
	start_height = rect_size.y - list.margin_top + list.margin_bottom
	height_set = true


func _reset_values():
	camera_fix.pressed = Singleton.disable_limits
	touch_controls.pressed = Singleton.touch_control
	mute_music.pressed = AudioServer.is_bus_mute(bus_music)
	mute_sfx.pressed = AudioServer.is_bus_mute(bus_sfx)
	show_timer.pressed = Singleton.timer.visible
	$List/CameraFix/Sprite.playing = camera_fix.pressed
	$List/TouchControls/Sprite.playing = touch_controls.pressed
	$List/MuteMusic/Sprite.playing = mute_music.pressed
	$List/MuteSFX/Sprite.playing = mute_sfx.pressed
	$List/ShowTimer/Sprite.playing = show_timer.pressed


func _process(_delta):
	manage_sizes()
	max_height = list.rect_size.y
	
	if visible:
		# If we just became visible, initalize and re-enable the menu.
		if !was_visible:
			enable_all_controls()
			# Reload current settings.
			_reset_values()
		
		# Set the actual settings.
		Singleton.disable_limits = camera_fix.pressed
		Singleton.touch_control = touch_controls.pressed
		AudioServer.set_bus_mute(bus_music, mute_music.pressed)
		AudioServer.set_bus_mute(bus_sfx, mute_sfx.pressed)
		Singleton.timer.visible = show_timer.pressed
		button_menu.visible = !Singleton.touch_control
		touch_menu.visible = Singleton.touch_control
	elif was_visible:
		# Just became invisible; make all controls reject mouse input
		disable_all_controls()
	was_visible = visible


func _on_OptionsMenu_gui_input(event):
	var scale = max(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1)
	# Read scroll wheel events.
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN:
			list.margin_top = max(list.margin_top - SCROLL_SPEED * scale, -(max_height - start_height) + list.margin_left)
			list.margin_bottom = list.margin_top - 16
		elif event.button_index == BUTTON_WHEEL_UP:
			list.margin_top = min(list.margin_top + SCROLL_SPEED * scale, 8)
			list.margin_bottom = list.margin_top - 16


func _notification(what):
	if what == NOTIFICATION_RESIZED and height_set:
		start_height = rect_size.y - list.margin_top + list.margin_bottom


var prev_scale = 1
func manage_sizes():
	var scale = max(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1)
	camera_fix.rect_scale = Vector2.ONE * scale
	touch_controls.rect_scale = Vector2.ONE * scale
	mute_music.rect_scale = Vector2.ONE * scale
	mute_sfx.rect_scale = Vector2.ONE * scale
	#locale_select.rect_scale = Vector2.ONE * scale
	#locale_select.margin_right = 0
	for node in get_tree().get_nodes_in_group("rebinds"):
		node.scale = scale
	if prev_scale != scale:
		camera_fix.rect_min_size = camera_fix.rect_min_size / prev_scale * scale
		touch_controls.rect_min_size = touch_controls.rect_min_size / prev_scale * scale
		mute_music.rect_min_size = mute_music.rect_min_size / prev_scale * scale
		mute_sfx.rect_min_size = mute_sfx.rect_min_size / prev_scale * scale
		#locale_select.rect_min_size.y = 32# * scaleZz
		for node in get_tree().get_nodes_in_group("rebinds"):
			node.rect_min_size.y = node.rect_min_size.y / prev_scale * scale
			
		prev_scale = scale


func enable_all_controls():
	# Set all controls to take mouse input.
	# ("STOP" here means stop parent nodes from also taking the input.)
	camera_fix.mouse_filter = MOUSE_FILTER_STOP
	touch_controls.mouse_filter = MOUSE_FILTER_STOP
	mute_music.mouse_filter = MOUSE_FILTER_STOP
	mute_sfx.mouse_filter = MOUSE_FILTER_STOP
	show_timer.mouse_filter = MOUSE_FILTER_STOP
	locale_select.mouse_filter = MOUSE_FILTER_STOP
	
	# Certain controls are nested in other scenes. Dig for those.
	for node in button_menu.get_node("Margin").get_children():
		if !node is Label: # Labels SHOULD ignore input, don't change them
			node.mouse_filter = MOUSE_FILTER_STOP
			# Go one level deeper too
			for child in node.get_children():
				if !child is Label: # Labels SHOULD ignore input, don't change them
					child.mouse_filter = MOUSE_FILTER_STOP
	for node in touch_menu.get_node("Margin").get_children():
		if !node is Label: # Labels SHOULD ignore input, don't change them
			node.mouse_filter = MOUSE_FILTER_STOP
			# Go one level deeper too
			for child in node.get_children():
				if !child is Label: # Labels SHOULD ignore input, don't change them
					child.mouse_filter = MOUSE_FILTER_STOP


func disable_all_controls():
	# Set all controls to ignore mouse input.
	camera_fix.mouse_filter = MOUSE_FILTER_IGNORE
	touch_controls.mouse_filter = MOUSE_FILTER_IGNORE
	mute_music.mouse_filter = MOUSE_FILTER_IGNORE
	mute_sfx.mouse_filter = MOUSE_FILTER_IGNORE
	show_timer.mouse_filter = MOUSE_FILTER_IGNORE
	locale_select.mouse_filter = MOUSE_FILTER_IGNORE
	
	# Certain controls are nested in other scenes. Dig for those.
	for node in button_menu.get_node("Margin").get_children():
		node.mouse_filter = MOUSE_FILTER_IGNORE
		# Go one level deeper too
		for child in node.get_children():
			child.mouse_filter = MOUSE_FILTER_IGNORE
	for node in touch_menu.get_node("Margin").get_children():
		node.mouse_filter = MOUSE_FILTER_IGNORE
		# Go one level deeper too
		for child in node.get_children():
			child.mouse_filter = MOUSE_FILTER_IGNORE
