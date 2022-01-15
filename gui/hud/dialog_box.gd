extends Panel

onready var player = $"/root/Main/Player"
onready var star = $Star

var loaded_lines = []
var line_index = 0
var char_roll = 1
var char_index = 1
var target_line = ""
var text_speed = 0.5
var pause_time = 0
var star_wobble = 0
var gui_size = 1
var swoop_timer = 0
var active = false

func insert_keybind_strings(input: String) -> String:
	var regex: RegEx = RegEx.new()
	regex.compile("\\[@b[^\\]]*\\]")
	var bind_tags: Array = regex.search_all(input)
	for tag_match in bind_tags:
		var tag_string: String = tag_match.get_string()
		var tag_bind = tag_string.substr(4, tag_string.length() - 5)
		input = input.replace(tag_string, InputMap.get_action_list(tag_bind)[0].as_text())
	return input


func say_line(index):
	$Text.bbcode_text = ""
	char_roll = 1
	char_index = 0
	
	#add line breaks
	var font = $Text.get_font("normal_font")
	var cumulative_length = 0
	var i = 0
#	if 
	target_line = insert_keybind_strings(TranslationServer.translate(loaded_lines[index]))
	while i < target_line.length():
#		if target_line[i] == "[":
#			while target_line[i] != "]" || target_line[i+1] == "[":
#				i += 1
#			i += 1
		var j = 0
		var word = " "
		var loop = true
		while i + j < target_line.length() && target_line[i + j] != " " && target_line[i + j] != "\n" && loop:
			if target_line[i + j] == "[":
				while i + j < target_line.length() - 1 && (target_line[i + j - 1] != "]" || target_line[i + j] == "["):
					j += 1
				if target_line[i + j] == " ":
					loop = false
				#word += target_line[i + j]
				#j -= 1
			if loop:
				word += target_line[i + j]
				j += 1
			
			
		#word += target_line[i + j]
		if i + j < target_line.length() && target_line[i + j] == "\n":
			cumulative_length = 0
		else:
			var added_length = font.get_string_size(word).x
			cumulative_length += added_length
			#print(word + str(cumulative_length))
			if cumulative_length >= 233:
				cumulative_length = added_length
				target_line = target_line.insert(i, "\n")
				i += 1
		i += j
		i += 1
	#pad the left side to prevent outline issues ._.
	target_line = " " + target_line.replace("\n", "\n ")
	visible = true
	active = true


func load_lines(lines):
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
				else:
					say_line(line_index)
		swoop_timer = min(swoop_timer + 1, 80)
		rect_scale = Vector2.ONE * gui_size
		rect_position = Vector2(OS.window_size.x / 2 - 128 * gui_size, OS.window_size.y + ((max(80 / swoop_timer, 5)) - 85) * gui_size)
	else:
		swoop_timer = min(swoop_timer + 0.75, 100)
		rect_scale = Vector2.ONE * gui_size
		rect_position = Vector2(OS.window_size.x / 2 - 128 * gui_size, OS.window_size.y + 20 - (100 / swoop_timer) * gui_size)
		if swoop_timer >= 100:
			visible = false
