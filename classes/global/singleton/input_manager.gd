extends Node

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

var default_input_map: String

func _ready():
	default_input_map = get_input_map_json_current()
	var file = File.new()
	if file.file_exists("user://controls.json"):
		load_input_map(get_input_map_json_saved())

func _process(_delta):
	if Input.is_action_just_pressed("fullscreen") and OS.get_name() != "HTML5":
		OS.window_fullscreen = !OS.window_fullscreen
	if Input.is_action_just_pressed("screen+") and OS.window_size.x + Singleton.DEFAULT_SIZE.x < OS.get_screen_size().x and OS.window_size.y + Singleton.DEFAULT_SIZE.y < OS.get_screen_size().y:
		OS.window_size.x += Singleton.DEFAULT_SIZE.x
		OS.window_size.y += Singleton.DEFAULT_SIZE.y
	if Input.is_action_just_pressed("screen-") and OS.window_size.x - Singleton.DEFAULT_SIZE.x >= Singleton.DEFAULT_SIZE.x:
		OS.window_size.x -= Singleton.DEFAULT_SIZE.x
		OS.window_size.y -= Singleton.DEFAULT_SIZE.y

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


func save_input_map(input_json):
	var file = File.new()
	file.open("user://controls.json", File.WRITE)
	file.store_string(input_json) # minimize the amount of time spent with the file open
	file.close()
