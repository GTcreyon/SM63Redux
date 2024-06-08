extends Button

enum GamepadBrand {
	NINTENDO,
	MICROSOFT,
	SONY
}

## 2D array of every button's name for every controller vendor.
## Some of these names have to be translateable, so it can't be const.
static var joypad_buttons: Array
## Translated name of input "Left Stick Left".
static var lstick_l: String
## Translated name of input "Left Stick Right".
static var lstick_r: String
## Translated name of input "Left Stick Up".
static var lstick_u: String
## Translated name of input "Left Stick Down".
static var lstick_d: String
## Translated name of input "Right Stick Left".
static var rstick_l: String
## Translated name of input "Right Stick Right".
static var rstick_r: String
## Translated name of input "Right Stick Up".
static var rstick_u: String
## Translated name of input "Right Stick Down".
static var rstick_d: String


@export var action_id: String = ""

var btn_scale: float: set = set_btn_scale
var locale_saved: String = ""

@onready var key_list = $KeyList
@onready var action_name = $ActionName


func _ready():
	var action_map = _get_action_map()
	action_name.text = action_map[action_id]
	
	# If another rebind hasn't cached it already, cache the appropriate set of
	# joypad button names for this translation.
	if len(joypad_buttons) == 0:
		_update_translations()
	
	# Generate initial display name
	update_list()
	# Update display name on resetting the keymap.
	$"../../../ResetBinds".reset.connect(Callable(self, "update_list"))


func _input(event):
	if button_pressed:
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
	var joy_brand = get_joypad_brand()
	
	for action in actions:
		if action is InputEventJoypadButton:
			if action.button_index > joypad_buttons.size():
				output += "(?)"
			else:
				output += "(%s)" % joypad_buttons[action.button_index][joy_brand]
		elif action is InputEventJoypadMotion:
			output += "(%s)" % get_joypad_motion_name(action.axis, action.axis_value)
		else:
			# TODO: make these translatable
			output += action.as_text()
		output += ", "
	# Trim the final comma for visual cleanliness.
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
			return lstick_l if value < 0 else lstick_r
		JOY_AXIS_LEFT_Y:
			return lstick_u if value < 0 else lstick_d
		JOY_AXIS_RIGHT_X:
			return rstick_l if value < 0 else rstick_r
		JOY_AXIS_RIGHT_Y:
			return rstick_u if value < 0 else rstick_d


func get_joypad_brand(): # need to get the gamepad brand so we can display correct button icons
	if Input.get_connected_joypads().size() > 0:
		var guid = Input.get_joy_guid(0)
		var vendor_id = guid.substr(8, 4)
		match vendor_id:
			"7e05":
				return GamepadBrand.NINTENDO
			"5e04":
				return GamepadBrand.MICROSOFT
			"1716", "7264", "4c05", "510a", "ce0f", "ba12":
				return GamepadBrand.SONY
			_:
				return 0
	else:
		return 0


func set_btn_scale(new_scale):
	btn_scale = new_scale
	action_name.scale = Vector2.ONE * new_scale
	key_list.scale = Vector2.ONE * new_scale
	key_list.pivot_offset.x = key_list.size.x


func _update_translations():
	joypad_buttons = _get_joypad_buttons()
	lstick_l = tr("Left Stick Left")
	lstick_r = tr("Left Stick Right")
	lstick_u = tr("Left Stick Up")
	lstick_d = tr("Left Stick Down")
	rstick_l = tr("Right Stick Left")
	rstick_r = tr("Right Stick Right")
	rstick_u = tr("Right Stick Up")
	rstick_d = tr("Right Stick Down")


func _get_joypad_buttons() -> Array:
	var start := tr("Start")
	var click_ls := tr("Left Stick Click")
	var click_rs := tr("Right Stick Click")
	var logo := tr("Logo")
	var dpad_u := tr("D-Up")
	var dpad_d := tr("D-Down")
	var dpad_l := tr("D-Left")
	var dpad_r := tr("D-Right")
	
	return [
		["B", "A", "X"],
		["A", "B", "O"],
		["Y", "X", "[]"],
		["X", "Y", "/\\"],
		["L", "LB", "L1"],
		["R", "RB", "R1"],
		["-", tr("Back"), tr("Select")],
		["+", start, start],
		[click_ls, click_ls, click_ls],
		[click_rs, click_rs, click_rs],
		["ZL", "LT", "L2"],
		["ZR", "RT", "R2"],
		[logo, logo, logo],
		[dpad_u, dpad_u, dpad_u],
		[dpad_d, dpad_d, dpad_d],
		[dpad_l, dpad_l, dpad_l],
		[dpad_r, dpad_r, dpad_r],
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
			# TODO: Called once per rebind option. Could be called once total.
			_update_translations()
			# Update the list.
			update_list()
