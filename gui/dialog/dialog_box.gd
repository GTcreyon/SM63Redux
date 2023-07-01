extends Control

const styles = {
	"talk":preload("res://gui/dialog/talk_box.tres"),
	"mario":preload("res://gui/dialog/nx_box.tres"),
	"luigi":preload("res://gui/dialog/nx_luigi_box.tres"),
	"wario":preload("res://gui/dialog/nx_wario_box.tres"),
	"sign":preload("res://gui/dialog/sign_box.tres"),
	"think":preload("res://gui/dialog/think_box.tres"),
}

const characters = {
	"toad":
		{
			"anger":preload("res://gui/dialog/faces/toad/anger.png"),
		},
	"luigi":
		[
			[
				"neutral",
				"sad",
			],
			
			[
				preload("res://gui/dialog/faces/luigi/neutral.png"),
				preload("res://gui/dialog/faces/luigi/sad.png"),
			],
		],
}

const DEFAULT_WIDTH = 320
const ICON_WIDTH = 40

@onready var player = $"/root/Main/Player"
@onready var star = $EdgeRight/Star
@onready var text_area = $Text
@onready var portrait = $EdgeLeft/Portrait
@onready var nameplate = $EdgeLeft/Name
@onready var edge_left = $EdgeLeft
@onready var block_left = $BlockLeft
@onready var sfx_next = $Next
@onready var sfx_close = $Close

var loaded_lines = []
var line_index = 0
var char_roll = 1
var char_index = 1
var target_line: String = ""
var raw_line: String = ""
var text_speed: float = 0.5
var pause_time = 0
var star_wobble = 0
var swoop_timer = 0
var active = false
var character_id = null
var character_name: String = ""
var width_offset: int = 0


func insert_keybind_strings(input: String) -> String:
	var regex: RegEx = RegEx.new()
	var err = regex.compile("\\[@b[^\\]]*\\]")
	if err != OK:
		Singleton.log_msg(err, Singleton.LogType.ERROR)
	var bind_tags: Array = regex.search_all(input)
	for tag_match in bind_tags:
		var tag_string: String = tag_match.get_string()
		var tag_bind = tag_string.substr(4, tag_string.length() - 5)
		input = input.replace(tag_string, InputMap.action_get_events(tag_bind)[0].as_text())
	return input


func refresh_returns(line):
	var font = text_area.get_font("normal_font")
	var cumulative_length = 0
	var i = 0
	while i < line.length():
		var j = 0
		var word = " "
		var loop = true
		while i + j < line.length() and line[i + j] != " " and line[i + j] != "\n" and loop:
			if line[i + j] == "[":
				while i + j < line.length() - 1 and (line[i + j - 1] != "]" or line[i + j] == "["):
					j += 1
				if line[i + j] == " ":
					loop = false
			if loop:
				word += line[i + j]
				j += 1
		
		
		if i + j < line.length() and line[i + j] == "\n":
			cumulative_length = 0
		else:
			var added_length = font.get_string_size(word).x
			cumulative_length += added_length
			if cumulative_length >= DEFAULT_WIDTH - 25 + width_offset:
				cumulative_length = added_length
				line = line.insert(i, "\n")
				i += 1
		i += j
		i += 1
	# Pad the left side to prevent outline cutoff
	line = " " + line.replace("\n", "\n ")
	return line


func say_line(index):
	text_area.text = ""
	char_roll = 1
	char_index = 0
	
	raw_line = insert_keybind_strings(TranslationServer.translate(loaded_lines[index]))
	target_line = refresh_returns(raw_line)
	visible = true
	active = true


func load_lines(lines):
	portrait.visible = false
	text_area.offset_left = 8
	character_id = null
	character_name = ""
	swoop_timer = 0
	star_wobble = 0
	loaded_lines = lines
	line_index = 0
	width_offset = 0
	say_line(0) # Say the first line


func _physics_process(_delta):
	if active:
		if star.animation == "ready" or star.offset.y != 0:
			star_wobble += 0.1
			star.offset.y = round(sin(-star_wobble) * 2)
		else:
			star_wobble = 0 # Prevent overflow lol
		if char_index < target_line.length():
			if Input.is_action_pressed("skip"):
				var regex = RegEx.new()
				regex.compile("\\[@[^\\]]*\\]") # Remove @ tags
				text_area.text = regex.sub(target_line, "", true)
				char_roll = target_line.length()
				char_index = char_roll
			else:
				star.animation = "wait"
			if pause_time <= 0:
				if floor(char_roll) > char_index:
					var looping = true
					var skip_char = false
					while looping and char_index < target_line.length(): # Prevents lag on tags
						match target_line[char_index]:
							"[":
								var tag = ""
								while target_line[char_index] != "]":
									tag += target_line[char_index]
									char_index += 1
									char_roll += 1
								tag += target_line[char_index]
								match tag[1]:
									"/":
										text_area.pop() # Closes tag
									"@":
										if tag[2] == "/":
											var _a = 0
										else:
											var subtag = tag.substr(2, tag.length() - 3)
											var args = subtag.split(",")
											match args[0]:
												"s":
													text_speed = float(args[1])
												"p":
													pause_time = float(args[1])
												"t":
													add_theme_stylebox_override("panel", styles[args[1]])
												"c":
													if args.size() < 2:
														portrait.visible = false
														target_line = refresh_returns(raw_line)
													else:
														portrait.visible = true
														character_id = args[1]
														if characters.has(character_id):
															if args.size() >= 3:
																portrait.texture = characters[character_id][1][int(args[2])]
														else:
															Singleton.log_msg("Unknown character \"%s\"." % character_id, Singleton.LogType.ERROR)
														target_line = refresh_returns(raw_line)
												"m":
													portrait.texture = characters[character_id][args[1]]
												"n":
													character_name = args[1]
												"w":
													width_offset = int(args[1])
													target_line = refresh_returns(raw_line)
												_:
													print_debug("Dialog: Unknown tag")
									_:
										text_area.append_bbcode(tag)
								if skip_char:
									char_roll += 1
									skip_char = false
								skip_char = true # Skips ahead 1 char to prevent doubling after a tag
							_:
								text_area.append_bbcode(target_line[char_index])
								if skip_char:
									char_roll += 1
									skip_char = false
								looping = false
						char_index = floor(char_roll)
				char_roll += text_speed
			else:
				pause_time -= text_speed
		else:
			star.animation = "ready"
			if Input.is_action_just_pressed("interact"):
				line_index += 1
				if loaded_lines.size() <= line_index:
					active = false
					player.read_pos_x = INF
					player.locked = false
					player.sprite.reading_sign = false
					swoop_timer = 0
					sfx_close.play()
				else:
					say_line(line_index)
					sfx_next.play()
		swoop_timer = min(swoop_timer + 1, 80)
		
		if character_id == null:
			offset_left = -((DEFAULT_WIDTH + width_offset) / 2.0) + 2
			edge_left.offset_left = -16
			block_left.offset_left = 12
		else:
			offset_left = -((DEFAULT_WIDTH - ICON_WIDTH + width_offset) / 2.0) + 2
			edge_left.offset_left = -56
			block_left.offset_left = -28
		size.x = DEFAULT_WIDTH + width_offset
		offset_top = ((max(80 / swoop_timer, 5)) - 85)
		
		if character_name == "":
			nameplate.visible = false
		else:
			nameplate.text = character_name
			nameplate.visible = true
	else:
		swoop_timer = min(swoop_timer + 0.75, 100)
		if character_id == null:
			offset_left = -((DEFAULT_WIDTH + width_offset)) / 2.0
		else:
			offset_left = -((DEFAULT_WIDTH - ICON_WIDTH + width_offset)) / 2.0
		offset_top = 20 - (100 / swoop_timer)
		if swoop_timer >= 100:
			visible = false
