extends Panel

onready var player = $"/root/Main/Player"
onready var button = $Button

var loaded_lines = []
var line_index = 0
var char_roll = 1
var char_index = 1
var target_line = ""
var text_speed = 1
var pause_time = 0

func say_line(index):
	$Text.bbcode_text = ""
	char_roll = 1
	char_index = 0
	#pad the left side to prevent outline issues ._.
	var sub_lines = loaded_lines[index].split("\n")
	for i in range(sub_lines.size()):
		sub_lines[i] = " " + sub_lines[i]
	target_line = sub_lines.join("\n")
	visible = true


func load_lines(lines):
	loaded_lines = lines
	line_index = 0
	say_line(0) #say the first line


func _process(_delta):
	if visible:
		if char_index < target_line.length() - 1:
			button.animation = "wait"
			if Input.is_action_just_pressed("skip"):
				var regex = RegEx.new()
				regex.compile("\\[@[^\\]]*\\]") #remove @ tags
				$Text.bbcode_text = regex.sub(target_line, "", true)
				char_roll = target_line.length() - 1
				char_index = char_roll
			if pause_time <= 0:
				if floor(char_roll) > char_index:
					var looping = true
					var skip_char = false
					while looping && char_index < target_line.length() - 1: #prevents lag on tags
						match target_line[char_index]:
							"[":
								var tag = ""
								while target_line[char_index] != "]":
									tag += target_line[char_index]
									char_index += 1
									char_roll += 1
								tag += target_line[char_index]
								print(tag)
								match tag[1]:
									"/":
										$Text.pop() #closes tag
									"@":
										if tag[2] == "/":
											var a = 0
										else:
											var subtag = tag.substr(2, tag.length() - 3)
											print(subtag)
											var args = subtag.split(",")
											match args[0]:
												"s":
													text_speed = float(args[1])
												"p":
													pause_time = float(args[1])
												_:
													print("Dialog: Unknown tag")
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
			button.animation = "ready"
			if Input.is_action_just_pressed("interact"):
				line_index += 1
				if loaded_lines.size() <= line_index:
					visible = false
					player.static_v = false
				else:
					say_line(line_index)
