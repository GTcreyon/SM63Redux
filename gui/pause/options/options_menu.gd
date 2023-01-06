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
var all_interactables = []
var bus_music = AudioServer.get_bus_index("Music")
var bus_sfx = AudioServer.get_bus_index("SFX")
var height_set = false
var start_height
var max_height
var was_visible = false
var was_paused = false


func _ready():
	_reset_values()
	start_height = rect_size.y - list.margin_top + list.margin_bottom
	height_set = true
	
	# Save a list of all interactable child controls for enabling+disabling.
	# (Best not run this every frame. Once-and-cache is more efficient.)
	all_interactables = get_all_interactable_controls(self)


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
		
	if Singleton.pause_menu and !was_paused:
		# Just became paused.
		enable_all_interactables()
	elif !Singleton.pause_menu and was_paused:
		# Just unpaused.
		disable_all_interactables()
	
	was_visible = visible
	was_paused = Singleton.pause_menu


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


func get_all_interactable_controls(this: Node):
	var returner = []
	
	for node in this.get_children():
		# If this node is any kind of button, add it to the list.
		# This should leave us with every interactable in the options menu,
		# but none of the labels or containers.
		if node is BaseButton:
			returner.append(node)
		# If this node has children, search those for buttons.
		# TODO: probably faster without recursion. How to do that?
		elif node.get_child_count() > 0:
			returner.append_array(get_all_interactable_controls(node))
	
	return returner


func enable_all_interactables():
	# Set all controls to take mouse events.
	# ("STOP" here means stop parent nodes from also taking the events.)
	for control in all_interactables:
		control.mouse_filter = MOUSE_FILTER_STOP


func disable_all_interactables():
	# Set all controls to ignore mouse events.
	for control in all_interactables:
		control.mouse_filter = MOUSE_FILTER_IGNORE
