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
			PoolStringArray([
				"neutral",
				"sad",
			]),
			
			[
				preload("res://gui/dialog/faces/luigi/neutral.png"),
				preload("res://gui/dialog/faces/luigi/sad.png"),
			],
		],
}

onready var player = $"/root/Main/Player"
onready var star = $Star
onready var text_area = $Text
onready var portrait = $Portrait
onready var nameplate = $EdgeLeft/Name
onready var edge_left = $EdgeLeft
onready var block_left = $BlockLeft
onready var sfx_next = $Next
onready var sfx_close = $Close

var loaded_lines = []
var line_index = 0
var char_roll = 1
var char_index = 1
var target_line : String = ""
var raw_line : String = ""
var text_speed : float = 0.5
var pause_time = 0
var star_wobble = 0
var gui_size = 1
var swoop_timer = 0
var active = false
var character_id = null
var character_name : String = ""

func insert_keybind_strings(input: String) -> String:
	var regex: RegEx = RegEx.new()
	var err = regex.compile("\\[@b[^\\]]*\\]")
	if err != OK:
		Singleton.log_msg(err, Singleton.LogType.ERROR)
	var bind_tags: Array = regex.search_all(input)
	for tag_match in bind_tags:
		var tag_string: String = tag_match.get_string()
		var tag_bind = tag_string.substr(4, tag_string.length() - 5)
		input = input.replace(tag_string, InputMap.get_action_list(tag_bind)[0].as_text())
	return input


func refresh_returns(line):
	var font = $Text.get_font("normal_font")
	var cumulative_length = 0
	var i = 0
	while i < line.length():
#		if line[i] == "[":
#			while line[i] != "]" || line[i+1] == "[":
#				i += 1
#			i += 1
		var j = 0
		var word = " "
		var loop = true
		while i + j < line.length() && line[i + j] != " " && line[i + j] != "\n" && loop:
			if line[i + j] == "[":
				while i + j < line.length() - 1 && (line[i + j - 1] != "]" || line[i + j] == "["):
					j += 1
				if line[i + j] == " ":
					loop = false
				#word += line[i + j]
				#j -= 1
			if loop:
				word += line[i + j]
				j += 1
			
			
		#word += line[i + j]
		if i + j < line.length() && line[i + j] == "\n":
			cumulative_length = 0
		else:
			var added_length = font.get_string_size(word).x
			cumulative_length += added_length
			if cumulative_length >= 232:# || (character_id != null && cumulative_length >= 233 - (47 - 8)):
				cumulative_length = added_length
				line = line.insert(i, "\n")
				i += 1
		i += j
		i += 1
	#pad the left side to prevent outline issues ._.
	line = " " + line.replace("\n", "\n ")
	return line

func say_line(index):
	$Text.bbcode_text = ""
	char_roll = 1
	char_index = 0
	
#	if 
	raw_line = insert_keybind_strings(TranslationServer.translate(loaded_lines[index]))
	target_line = refresh_returns(raw_line)
	visible = true
	active = true


func load_lines(lines):
	portrait.visible = false
	text_area.margin_left = 8
	character_id = null
	character_name = ""
	swoop_timer = 0
	star_wobble = 0
	loaded_lines = lines
	line_index = 0
	say_line(0) #say the first line


func _process(_delta):
	if active:
		if star.animation == "ready" || star.offset.y != 0:
			star_wobble += 0.1
			star.offset.y = round(sin(-star_wobble) * 2)
		else:
			star_wobble = 0 #prevent overflow lol
		if char_index < target_line.length():
			if Input.is_action_pressed("skip"):
				var regex = RegEx.new()
				regex.compile("\\[@[^\\]]*\\]") #remove @ tags
				$Text.bbcode_text = regex.sub(target_line, "", true)
				char_roll = target_line.length()
				char_index = char_roll
			else:
				star.animation = "wait"
			if pause_time <= 0:
				if floor(char_roll) > char_index:
					var looping = true
					var skip_char = false
					while looping && char_index < target_line.length(): #prevents lag on tags
						match target_line[char_index]:
							"[":
								var tag = ""
								while target_line[char_index] != "]":
									tag += target_line[char_index]
									char_index += 1
									char_roll += 1
								tag += target_line[char_index]
								#print(tag)
								match tag[1]:
									"/":
										$Text.pop() #closes tag
									"@":
										if tag[2] == "/":
											var _a = 0
										else:
											var subtag = tag.substr(2, tag.length() - 3)
											#print(subtag)
											var args = subtag.split(",")
											match args[0]:
												"s":
													text_speed = float(args[1])
												"p":
													pause_time = float(args[1])
												"t":
													add_stylebox_override("panel", styles[args[1]])
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
												_:
													print_debug("Dialog: Unknown tag")
									_:
										$Text.append_bbcode(tag)
								if skip_char:
									char_roll += 1
									skip_char = false
								skip_char = true #skips ahead 1 char to prevent doubling after a tag
							_:
								$Text.append_bbcode(target_line[char_index])
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
				#print($Text.text)
				line_index += 1
				if loaded_lines.size() <= line_index:
					active = false
					player.sign_x = null
					player.static_v = false
					swoop_timer = 0
					sfx_close.play()
				else:
					say_line(line_index)
					sfx_next.play()
		swoop_timer = min(swoop_timer + 1, 80)
		rect_scale = Vector2.ONE * gui_size
#		if Input.is_action_pressed("interact"):
#			star.animation = "wait"
#		else:
#			star.animation = "ready"
		if character_id == null:
			rect_position.x = OS.window_size.x / 2 - 128 * gui_size
			edge_left.margin_left = -16
			block_left.margin_left = 12
		else:
			rect_position.x = OS.window_size.x / 2 - 108 * gui_size
			edge_left.margin_left = -56
			block_left.margin_left = -28
		rect_position.y = OS.window_size.y + ((max(80 / swoop_timer, 5)) - 85) * gui_size
			
		if character_name == "":
			nameplate.visible = false
		else:
			nameplate.text = character_name
			nameplate.visible = true
	else:
		swoop_timer = min(swoop_timer + 0.75, 100)
		rect_scale = Vector2.ONE * gui_size
		if character_id == null:
			rect_position.x = OS.window_size.x / 2 - 128 * gui_size
		else:
			rect_position.x = OS.window_size.x / 2 - 108 * gui_size
		rect_position.y = OS.window_size.y + 20 * gui_size - (100 / swoop_timer) * gui_size
		if swoop_timer >= 100:
			visible = false
