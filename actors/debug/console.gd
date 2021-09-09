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
		"w":
			var path
			if len(args) == 1:
				output("No second argument. (really? smh. read the api!)")
				return
			match args[1]:
				"basin":
					path = "res://scenes/test/basin.tscn"
				"main":
					path = "res://main.tscn"
				"t1":
					path = "res://scenes/tutorial_1/tutorial_1_1.tscn"
				"t1r2":
					path = "res://scenes/tutorial_1/tutorial_1_2.tscn"
				"t1r3":
					path = "res://scenes/tutorial_1/tutorial_1_3.tscn"
				"t1r4":
					path = "res://scenes/tutorial_1/tutorial_1_4.tscn"
				"custom":
					path = "res://scenes/digtest/digtest.tscn"
				_:
					path = ""
			if path == "":
				output("Scene does not exist. (learn to spell you baguette)")
			else:
				var err = get_tree().change_scene(path)
				if err == OK:
					output("Warped to " + path)
				else:
					output("Error: " + err)
		"scene":
			var scene = "res://" + args[1] + ".tscn"
			var file_check = File.new()
			if file_check.file_exists(scene):
				var err = get_tree().change_scene(scene)
				if err == OK:
					output("Warped to " + scene)
				else:
					output("Error: " + err)
			else:
				output("Scene does not exist. (again, learn to spell!!!)")
		"water":
			$"/root/Singleton".water = int(args[1])
		"c":
			$"/root/Singleton".classic = !$"/root/Singleton".classic
		"death":
			$"/root/Main/Player".take_damage(8)
			output("WAIT WHAT NO!!!")
		_:
			output("Unknown command. (imagine not knowing a command, can't be me :dabs:)")


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
