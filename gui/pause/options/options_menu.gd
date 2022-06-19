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
onready var locale_select = $List/LocaleSelect
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
		inst.add_to_group("rebinds")
		list.add_child(inst)


func _process(_delta):
	manage_sizes()
	max_height = list.rect_size.y
	Singleton.disable_limits = camera_fix.pressed
	Singleton.force_touch = touch_controls.pressed
	AudioServer.set_bus_mute(bus_music, mute_music.pressed)
	AudioServer.set_bus_mute(bus_sfx, mute_sfx.pressed)


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
	if what == NOTIFICATION_RESIZED && height_set:
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
		#locale_select.rect_min_size.y = 32# * scale
		for node in get_tree().get_nodes_in_group("rebinds"):
			node.rect_min_size.y = node.rect_min_size.y / prev_scale * scale
			
		prev_scale = scale


func save_input_map():
	var save_dict = {}
	for key in InputMap.get_actions():
		if WHITELISTED_ACTIONS.has(key):
			for action in InputMap.get_action_list(key):
				if !save_dict.has(key):
					save_dict[key] = []
				var key_entry = save_dict[key]
				match action.get_class():
					"InputEventKey":
						key_entry.append("k:%d" % action.scancode)
					"InputEventJoypadButton":
						key_entry.append("b:%d" % action.button_index)
					"InputEventJoypadMotion":
						key_entry.append("a:%d;%d" % [action.axis, action.axis_value])
	var content = to_json(save_dict)
	var file = File.new()
	file.open("user://controls.json", File.WRITE)
	file.store_string(content) # minimise the amount of time spent with the file open
	file.close()
