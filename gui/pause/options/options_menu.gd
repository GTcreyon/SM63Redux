extends Control

const SCROLL_SPEED = 16

var _bus_music = AudioServer.get_bus_index("Music")
var _bus_sfx = AudioServer.get_bus_index("SFX")
var _bus_sfx_underwater = AudioServer.get_bus_index("SFX Clear In Water")
var _prev_visible = false

@onready var _camera_fix = $ScrollContainer/List/CameraFix
@onready var _touch_controls = $ScrollContainer/List/TouchControls
@onready var _mute_music = $ScrollContainer/List/MuteMusic
@onready var _mute_sfx = $ScrollContainer/List/MuteSFX
@onready var _show_timer = $ScrollContainer/List/ShowTimer
@onready var _locale_select = $ScrollContainer/List/LocaleSelect

@onready var _button_menu = $ScrollContainer/List/ButtonMenu
@onready var _touch_menu = $ScrollContainer/List/TouchMenu


func _ready():
	_reset_values()


func _reset_values():
	# Set controls by reading their destination values.
	_camera_fix.set_pressed(Singleton.disable_limits)
	_touch_controls.set_pressed(Singleton.touch_control)
	_mute_music.set_pressed(AudioServer.is_bus_mute(_bus_music))
	_mute_sfx.set_pressed(AudioServer.is_bus_mute(_bus_sfx))
	_show_timer.set_pressed(Singleton.timer.visible)


func _process(_delta):
	if visible:
		if !_prev_visible:
			# We just became visible. Reload current settings.
			_reset_values()
		
		# Copy values from controls to their destinations.
		Singleton.disable_limits = _camera_fix.pressed
		Singleton.touch_control = _touch_controls.pressed
		AudioServer.set_bus_mute(_bus_music, _mute_music.pressed)
		AudioServer.set_bus_mute(_bus_sfx, _mute_sfx.pressed)
		AudioServer.set_bus_mute(_bus_sfx_underwater, _mute_sfx.pressed)
		Singleton.timer.visible = _show_timer.pressed
		_button_menu.visible = !Singleton.touch_control
		_touch_menu.visible = Singleton.touch_control
	
	# Save these for checking against next frame.
	_prev_visible = visible
