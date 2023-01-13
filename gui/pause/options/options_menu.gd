extends Control

const SCROLL_SPEED = 16

var _all_interactables = []
var _bus_music = AudioServer.get_bus_index("Music")
var _bus_sfx = AudioServer.get_bus_index("SFX")
var _height_set = false
var _start_height
var _max_height
var _prev_visible = false
var _prev_paused = false
var _prev_scale = 1

onready var _root_list = $List
onready var _camera_fix = $List/CameraFix
onready var _touch_controls = $List/TouchControls
onready var _mute_music = $List/MuteMusic
onready var _mute_sfx = $List/MuteSFX
onready var _show_timer = $List/ShowTimer
onready var _locale_select = $List/LocaleSelect
onready var _button_menu = $List/ButtonMenu
onready var _touch_menu = $List/TouchMenu


func _ready():
	_reset_values()
	_start_height = rect_size.y - _root_list.margin_top + _root_list.margin_bottom
	_height_set = true
	
	# Save a list of all interactable child controls for enabling+disabling.
	# (Best not run this every frame. Once-and-cache is more efficient.)
	_all_interactables = _get_all_interactable_controls(self)


func _process(_delta):
	_manage_sizes()
	_max_height = _root_list.rect_size.y
	
	if visible:
		if !_prev_visible:
			# We just became visible. Reload current settings.
			_reset_values()
		
		# Copy values from controls to their destinations.
		Singleton.disable_limits = _camera_fix.pressed
		Singleton.touch_control = _touch_controls.pressed
		AudioServer.set_bus_mute(_bus_music, _mute_music.pressed)
		AudioServer.set_bus_mute(_bus_sfx, _mute_sfx.pressed)
		Singleton.timer.visible = _show_timer.pressed
		_button_menu.visible = !Singleton.touch_control
		_touch_menu.visible = Singleton.touch_control
		
	if Singleton.pause_menu and !_prev_paused:
		# We just became paused. Allow interacting with controls.
		_enable_all_interactables()
	elif !Singleton.pause_menu and _prev_paused:
		# We just unpaused. Keep player from changing stuff mid-gameplay!
		_disable_all_interactables()
	
	# Save these for checking against next frame.
	_prev_visible = visible
	_prev_paused = Singleton.pause_menu


func _notification(what):
	if what == NOTIFICATION_RESIZED and _height_set:
		_start_height = rect_size.y - _root_list.margin_top + _root_list.margin_bottom


func _on_OptionsMenu_gui_input(event):
	var scale = max(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1)
	# Read scroll wheel events.
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN:
			_root_list.margin_top = max(_root_list.margin_top - SCROLL_SPEED * scale,
					-(_max_height - _start_height) + _root_list.margin_left)
			_root_list.margin_bottom = _root_list.margin_top - 16
		elif event.button_index == BUTTON_WHEEL_UP:
			_root_list.margin_top = min(_root_list.margin_top + SCROLL_SPEED * scale, 8)
			_root_list.margin_bottom = _root_list.margin_top - 16


func _reset_values():
	# Set controls by reading their destination values.
	_camera_fix.pressed = Singleton.disable_limits
	_touch_controls.pressed = Singleton.touch_control
	_mute_music.pressed = AudioServer.is_bus_mute(_bus_music)
	_mute_sfx.pressed = AudioServer.is_bus_mute(_bus_sfx)
	_show_timer.pressed = Singleton.timer.visible
	# Let checked tickboxes show their checks.
	$List/CameraFix/Sprite.playing = _camera_fix.pressed
	$List/TouchControls/Sprite.playing = _touch_controls.pressed
	$List/MuteMusic/Sprite.playing = _mute_music.pressed
	$List/MuteSFX/Sprite.playing = _mute_sfx.pressed
	$List/ShowTimer/Sprite.playing = _show_timer.pressed


func _manage_sizes():
	var scale = max(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1)
	_camera_fix.rect_scale = Vector2.ONE * scale
	_touch_controls.rect_scale = Vector2.ONE * scale
	_mute_music.rect_scale = Vector2.ONE * scale
	_mute_sfx.rect_scale = Vector2.ONE * scale
	#_locale_select.rect_scale = Vector2.ONE * scale
	#_locale_select.margin_right = 0
	for node in get_tree().get_nodes_in_group("rebinds"):
		node.scale = scale
	if _prev_scale != scale:
		_camera_fix.rect_min_size = _camera_fix.rect_min_size / _prev_scale * scale
		_touch_controls.rect_min_size = _touch_controls.rect_min_size / _prev_scale * scale
		_mute_music.rect_min_size = _mute_music.rect_min_size / _prev_scale * scale
		_mute_sfx.rect_min_size = _mute_sfx.rect_min_size / _prev_scale * scale
		#_locale_select.rect_min_size.y = 32# * scaleZz
		for node in get_tree().get_nodes_in_group("rebinds"):
			node.rect_min_size.y = node.rect_min_size.y / _prev_scale * scale
		
		_prev_scale = scale


func _get_all_interactable_controls(this: Node):
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
			returner.append_array(_get_all_interactable_controls(node))
	
	return returner


func _enable_all_interactables():
	# Set all controls to take mouse events.
	# ("STOP" here means stop parent nodes from also taking the events.)
	for control in _all_interactables:
		control.mouse_filter = MOUSE_FILTER_STOP


func _disable_all_interactables():
	# Set all controls to ignore mouse events.
	for control in _all_interactables:
		control.mouse_filter = MOUSE_FILTER_IGNORE
	
	# Forcibly close locale-select popup.
	# The intent is that NO control is able to be interacted with, after all.
	(_locale_select as OptionButton).get_popup().visible = false
