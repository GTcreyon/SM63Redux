extends Control

onready var logger = $Logger
onready var input_line = $Input

var history = []
var hist_index = 0


func output(msg):
	logger.text += "\n" + str(msg)


func run_command(cmd):
	hist_index = 0
	history.append(cmd)
	var args = cmd.split(" ")
	match args[0]:
		"s":
			var path
			match args[1]:
				"creyon":
					path = "res://scenes/test/creyon.tscn"
				"main":
					path = "res://main.tscn"
				_:
					path = ""
			if path == "":
				output("Scene does not exist.")
			else:
				get_tree().change_scene(path)
		"scene":
			var scene = "res://" + args[1] + ".tscn"
			var file_check = File.new()
			if file_check.file_exists(scene):
				get_tree().change_scene(scene)
			else:
				output("Scene does not exist.")
		_:
			output("Unknown command.")


func _process(_delta):
	if Input.is_action_just_pressed("debug"):
		visible = !visible
		input_line.grab_focus()
	if visible:
		if Input.is_action_just_pressed("ui_accept"):
			run_command(input_line.text)
			input_line.text = ""
		if Input.is_action_just_pressed("ui_up"):
			if hist_index < history.size():
				input_line.text = history[hist_index]
				hist_index += 1
