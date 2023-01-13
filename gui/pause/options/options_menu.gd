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
	max_height = list.rect_size.y
	if visible:
		if !was_visible:
			 _reset_values()
		Singleton.disable_limits = camera_fix.pressed
		Singleton.touch_control = touch_controls.pressed
		AudioServer.set_bus_mute(bus_music, mute_music.pressed)
		AudioServer.set_bus_mute(bus_sfx, mute_sfx.pressed)
		Singleton.timer.visible = show_timer.pressed
		button_menu.visible = !Singleton.touch_control
		touch_menu.visible = Singleton.touch_control
	was_visible = visible


func _on_OptionsMenu_gui_input(event):
	var scale = max(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1)
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
