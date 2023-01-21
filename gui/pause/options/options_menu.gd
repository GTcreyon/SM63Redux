extends Control

const SCROLL_SPEED = 16

var _bus_music = AudioServer.get_bus_index("Music")
var _bus_sfx = AudioServer.get_bus_index("SFX")
var _height_set = false
var _start_height
var _max_height
var _prev_visible = false

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

func _process(_delta):
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
	
	# Save these for checking against next frame.
	_prev_visible = visible


func _notification(what):
	if what == NOTIFICATION_RESIZED and _height_set:
		_start_height = rect_size.y - _root_list.margin_top + _root_list.margin_bottom


func _on_OptionsMenu_gui_input(event):
	var scale = Singleton.get_screen_scale(1)
	# Read scroll wheel events.
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN:
			_root_list.margin_top = max(_root_list.margin_top - SCROLL_SPEED * scale,
					-(_max_height - _start_height) + _root_list.margin_left)
			_root_list.margin_bottom = _root_list.margin_top - 16
		elif event.button_index == BUTTON_WHEEL_UP:
			_root_list.margin_top = min(_root_list.margin_top + SCROLL_SPEED * scale, 8)
			_root_list.margin_bottom = _root_list.margin_top - 16
