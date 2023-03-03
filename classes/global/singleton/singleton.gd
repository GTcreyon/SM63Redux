extends Node

const DEFAULT_SIZE = Vector2(640, 360)
const VERSION = "v0.2.0.alpha"
const LD_VERSION = 0
const LOCALES = [
	["en", "English"],
	["es", "Español"],
	["fr", "Français"],
	["pt-BR", "Português"],
	["it", "Italiano"],
	["nl", "Nederlands"],
]
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

enum n { # FLUDD enum
	none,
	hover,
	rocket,
	turbo,
}

onready var console = $Console
onready var timer = $Timer

var classic = false

# Player data that persists between scenes
var warp_location # Location player spawns after a warp
var warp_data: InterSceneData

var coin_total = 0
var red_coin_total = 0
var rng = RandomNumberGenerator.new()
var enter = 0 # apparently unused?
var direction = 0 # apparently unused?
var meter_progress = 0
var pause_menu = false
var line_count: int = 0
var disable_limits = false
var touch_control = false
var ld_buffer = PoolByteArray([])
var meta_paused = false
var meta_pauses = {
	"feedback":false,
	"console":false,
}
var default_input_map: String

enum LogType {
	INFO,
	WARNING,
	ERROR,
}

func log_msg(msg: String, type: int = LogType.INFO):
	var color_tag: String = "[color=#"
	match type:
		LogType.INFO:
			color_tag += "f9e8e8"
		LogType.WARNING:
			color_tag += "f2d67c"
		LogType.ERROR:
			color_tag += "f28d7c"
	color_tag += "]"
		
	console.logger.append_bbcode("\n" + color_tag + str(msg) + "[/color]")
	line_count += 1
	print(msg)


func _ready():
	touch_control = OS.get_name() == "Android"
	rng.seed = hash("2401")
	default_input_map = get_input_map_json_current()
	var file = File.new()
	if file.file_exists("user://controls.json"):
		load_input_map(get_input_map_json_saved())


func _process(_delta):
	var sfx = AudioServer.get_bus_index("SFX")
	var music = AudioServer.get_bus_index("Music")
	if Input.is_action_just_pressed("volume_sfx-"):
		AudioServer.set_bus_volume_db(sfx, AudioServer.get_bus_volume_db(sfx) - 1)
	if Input.is_action_just_pressed("volume_sfx+"):
		AudioServer.set_bus_volume_db(sfx, AudioServer.get_bus_volume_db(sfx) + 1)
	if Input.is_action_just_pressed("volume_music-"):
		AudioServer.set_bus_volume_db(music, AudioServer.get_bus_volume_db(music) - 1)
	if Input.is_action_just_pressed("volume_music+"):
		AudioServer.set_bus_volume_db(music, AudioServer.get_bus_volume_db(music) + 1)


# Get a scaling factor based on the window dimensions
func get_screen_scale(mode: int = 0, threshold: float = -1) -> int:
	var scale_vec = OS.window_size / Singleton.DEFAULT_SIZE
	var rounded = Vector2.ONE
	if threshold == -1:
		match mode:
			-1:
				# Minimise
				threshold = 0.875
			1:
				# Maximise
				threshold = 0.125
			_:
				threshold = 0.5
	
	if fmod(scale_vec.x, 1) < threshold:
		rounded.x = floor(scale_vec.x)
	else:
		rounded.x = ceil(scale_vec.x)
	if fmod(scale_vec.y, 1) < threshold:
		rounded.y = floor(scale_vec.y)
	else:
		rounded.y = ceil(scale_vec.y)
	
	var scale_x: int = int(max(rounded.x, 1))
	var scale_y: int = int(max(rounded.y, 1))
	
	match mode:
		-1:
			return int(min(scale_x, scale_y))
		1:
			return int(max(scale_x, scale_y))
		_:
			return int(ceil(sqrt(scale_x * scale_y)))


# Warp to the scene specified by string.
# Player is passed as second argument so the player's state can
# be carried over into the next scene. If null is passed instead,
# no player data will be carried to the next scene.
func warp_to(path: String, player: PlayerCharacter, position: Vector2 = Vector2.INF):
	if player != null:
		# Save player data for next room.
		warp_data = InterSceneData.new(player)
	if position != Vector2.INF:
		warp_location = position
	
	# Prepare flag server for this next room.
	FlagServer.reset_assign_id()

	# Reset speedrun timer if warping to the start of the game.
	if path == SpeedrunTimer.RESET_SCENE_PATH:
		timer.running = true
		timer.frames = 0
		timer.split_frames = 0
	# Either way, mark a new split.
	timer.split_timer()
	
	# Do the actual warp.
	# warning-ignore:RETURN_VALUE_DISCARDED
	get_tree().call_deferred("change_scene", path)


# Sets a certain pause label - when all pause labels are false, gameplay takes place
func set_pause(label: String, set: bool):
	meta_pauses[label] = set
	meta_paused = false
	for pause in meta_pauses:
		meta_paused = meta_paused or meta_pauses[pause]


func get_input_map_json_saved():
	var file = File.new()
	file.open("user://controls.json", File.READ)
	var content = file.get_as_text()
	file.close()
	return content


func load_input_map(input_json):
	var load_dict = parse_json(input_json)
	for key in load_dict:
		InputMap.action_erase_events(key)
		for action in load_dict[key]:
			var type = action[0]
			var body = action.substr(2)
			var event
			match type:
				"k":
					event = InputEventKey.new()
					event.scancode = int(body)
				"b":
					event = InputEventJoypadButton.new()
					event.button_index = int(body)
				"a":
					var args = body.split(";")
					event = InputEventJoypadMotion.new()
					event.axis = int(args[0])
					event.axis_value = int(args[1])
			InputMap.action_add_event(key, event)


func get_input_map_json_current():
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
	return to_json(save_dict)


func save_input_map_current() -> void:
	save_input_map(get_input_map_json_current())


func save_input_map(input_json):
	var file = File.new()
	file.open("user://controls.json", File.WRITE)
	file.store_string(input_json) # minimize the amount of time spent with the file open
	file.close()
