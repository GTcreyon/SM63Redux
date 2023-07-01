extends Button

@export var action_id: String = ""

@onready var key_list = $KeyList
@onready var action_name = $ActionName
var btn_scale: float: set = set_btn_scale
var locale_saved: String = ""


func _ready():
	var action_map = _get_action_map()
	action_name.text = action_map[action_id]
	update_list()


func _input(event):
	if pressed:
		if event is InputEventKey or event is InputEventJoypadButton or (event is InputEventJoypadMotion and abs(event.axis_value) > 0.25):
			Singleton.get_node("SFX/Confirm").play()
			InputMap.action_add_event(action_id, event)
			unpress()
			Singleton.save_input_map(Singleton.get_input_map_json_current())
			update_list()


func update_list():
	key_list.text = join_action_array(InputMap.action_get_events(action_id))


func join_action_array(actions) -> String:
	var output: String = ""
	for action in actions:
		if action is InputEventJoypadButton:
			var buttons = _get_joypad_buttons()
			if action.button_index > buttons.size():
				output += "(?)"
			else:
				output += "(%s)" % buttons[action.button_index][get_brand_id()]
		elif action is InputEventJoypadMotion:
			output += "(%s)" % get_joypad_motion_name(action.axis, action.axis_value)
		else:
			# TODO: make these translatable
			output += action.as_text()
		output += ", "
	output = output.trim_suffix(", ")
	return output


func _on_RebindOption_pressed():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		Singleton.get_node("SFX/Back").play()
		InputMap.action_erase_events(action_id)
		Singleton.save_input_map(Singleton.get_input_map_json_current())
		update_list()
	else:
		Singleton.get_node("SFX/Next").play()
		action_name.add_theme_color_override("font_color", Color.GREEN)
		key_list.add_theme_color_override("font_color", Color.GREEN)
		

func get_brand_id(): # need to get the gamepad brand so we can display correct button icons
	if Input.get_connected_joypads().size() > 0:
		var guid = Input.get_joy_guid(0)
		var vendor_id = guid.substr(8, 4)
		match vendor_id:
			"7e05": # nintendo
				return 0
			"5e04": # microsoft
				return 1
			"1716", "7264", "4c05", "510a", "ce0f", "ba12": # sony
				return 2
			_:
				return 0
	else:
		return 0


func _on_RebindOption_mouse_entered():
	if !button_pressed:
		action_name.add_theme_color_override("font_color", Color.AQUA)
		key_list.add_theme_color_override("font_color", Color.AQUA)


func _on_RebindOption_mouse_exited():
	if !button_pressed:
		action_name.add_theme_color_override("font_color", Color.WHITE)
		key_list.add_theme_color_override("font_color", Color.WHITE)


func unpress():
	set_pressed_no_signal(false)
	action_name.add_theme_color_override("font_color", Color.WHITE)
	key_list.add_theme_color_override("font_color", Color.WHITE)


func get_joypad_motion_name(axis: int, value: float):
	match axis:
		JOY_AXIS_LEFT_X:
			return tr("Left Stick Left") if value < 0 else tr("Left Stick Right")
		JOY_AXIS_LEFT_Y:
			return tr("Left Stick Up") if value < 0 else tr("Left Stick Down")
		JOY_AXIS_RIGHT_X:
			return tr("Right Stick Left") if value < 0 else tr("Right Stick Right")
		JOY_AXIS_RIGHT_Y:
			return tr("Right Stick Up") if value < 0 else tr("Right Stick Down")


func set_btn_scale(new_scale):
	btn_scale = new_scale
	action_name.scale = Vector2.ONE * new_scale
	key_list.scale = Vector2.ONE * new_scale
	key_list.pivot_offset.x = key_list.size.x


func _process(_delta):
	update_list()


func _get_joypad_buttons() -> Array:
	return [
		["B", "A", "X"],
		["A", "B", "O"],
		["Y", "X", "[]"],
		["X", "Y", "/\\"],
		["L", "LB", "L1"],
		["R", "RB", "R1"],
		["-", tr("Back"), tr("Select")],
		["+", tr("Start"), tr("Start")],
		[tr("Left Stick Click"), tr("Left Stick Click"), tr("Left Stick Click")],
		[tr("Right Stick Click"), tr("Right Stick Click"), tr("Right Stick Click")],
		["ZL", "LT", "L2"],
		["ZR", "RT", "R2"],
		[tr("Logo"), tr("Logo"), tr("Logo")],
		[tr("D-Up"), tr("D-Up"), tr("D-Up")],
		[tr("D-Down"), tr("D-Down"), tr("D-Down")],
		[tr("D-Left"), tr("D-Left"), tr("D-Left")],
		[tr("D-Right"), tr("D-Right"), tr("D-Right")],
	]

func _get_action_map() -> Dictionary:
	return {
		"left":tr("Left"),
		"right":tr("Right"),
		"jump":tr("Jump"),
		"dive":tr("Dive"),
		"spin":tr("Spin"),
		"pound":tr("Ground Pound"),
		"fludd":tr("Use FLUDD"),
		"switch_fludd":tr("Switch FLUDD Nozzle"),
		"pause":tr("Pause"),
		"interact":tr("Interact"),
		"skip":tr("Skip Text"),
		"zoom+":tr("Zoom In"),
		"zoom-":tr("Zoom Out"),
		"semi":tr("Power Swim"),
		"reset":tr("Reset Run"),
		"timer_show":tr("Show Timer"),
		"mute_music":tr("Mute Music"),
		"mute_sfx":tr("Mute SFX"),
		"volume_music+":tr("Music Volume +"),
		"volume_music-":tr("Music Volume -"),
		"volume_sfx+":tr("SFX Volume +"),
		"volume_sfx-":tr("SFX Volume -"),
		"fullscreen":tr("Fullscreen"),
		"screen+":tr("Screen Size +"),
		"screen-":tr("Screen Size -"),
		"feedback":tr("Open Feedback Menu"),
		"debug":tr("Open Debug Console"),
	}


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_TRANSLATION_CHANGED:
			update_list()
