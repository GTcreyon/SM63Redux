extends Control

const SCROLL_SPEED = 16
const WHITELISTED_ACTIONS = [
	"left",
	"right",
	"jump",
	"dive",
	"spin",
	"pound",
	"fludd",
	"switch_fludd",
	"pause",
	"interact",
	"skip",
	"zoom+",
	"zoom-",
	"semi",
	"reset",
	"timer_show",
	"mute_music",
	"mute_sfx",
	"volume_music+",
	"volume_music-",
	"volume_sfx+",
	"volume_sfx-",
	"fullscreen",
	"screen+",
	"screen-",
	"feedback",
	"debug",
]
const PREFAB_REBIND_OPTION = preload("res://gui/pause/options/rebind_option.tscn")

onready var list = $List
onready var camera_fix = $List/CameraFix
onready var touch_controls = $List/TouchControls
onready var mute_music = $List/MuteMusic
onready var mute_sfx = $List/MuteSFX
onready var show_timer = $List/ShowTimer
var bus_music = AudioServer.get_bus_index("Music")
var bus_sfx = AudioServer.get_bus_index("SFX")
var height_set = false
var start_height
var max_height


func _ready():
	camera_fix.pressed = Singleton.disable_limits
	touch_controls.pressed = Singleton.touch_controls()
	mute_music.pressed = AudioServer.is_bus_mute(bus_music)
	mute_sfx.pressed = AudioServer.is_bus_mute(bus_sfx)
	$List/CameraFix/Sprite.playing = camera_fix.pressed
	$List/TouchControls/Sprite.playing = touch_controls.pressed
	$List/MuteMusic/Sprite.playing = mute_music.pressed
	$List/MuteSFX/Sprite.playing = mute_sfx.pressed
	start_height = rect_size.y - list.margin_top + list.margin_bottom
	height_set = true
	for action in WHITELISTED_ACTIONS:
		var inst = PREFAB_REBIND_OPTION.instance()
		inst.action_id = action
		list.add_child(inst)


func _process(_delta):
	max_height = list.rect_size.y
	Singleton.disable_limits = camera_fix.pressed
	Singleton.force_touch = touch_controls.pressed
	AudioServer.set_bus_mute(bus_music, mute_music.pressed)
	AudioServer.set_bus_mute(bus_sfx, mute_sfx.pressed)


func _on_OptionsMenu_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_DOWN:
			list.margin_top = max(list.margin_top - SCROLL_SPEED, -(max_height - start_height) + list.margin_left)
			list.margin_bottom = list.margin_top - 16
		elif event.button_index == BUTTON_WHEEL_UP:
			list.margin_top = min(list.margin_top + SCROLL_SPEED, 8)
			list.margin_bottom = list.margin_top - 16


func _notification(what):
	if what == NOTIFICATION_RESIZED && height_set:
		start_height = rect_size.y - list.margin_top + list.margin_bottom
