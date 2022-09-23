extends Control

onready var logger = $Logger
onready var input_line = $Input

var history : PoolStringArray = []
var hist_index = 0
var req = HTTPRequest.new()
var hook_name = "Ingame Webhook"
var line_count : int = 0

func _ready():
	add_child(req)


func run_command(cmd: String):
	if cmd != "":
		hist_index = 0
		if cmd[0] == "/":
			cmd = cmd.substr(1)
		history.append(cmd)
		var args: PoolStringArray = cmd.split(" ")
		match args[0].to_lower():
			"w":
				var path
				if len(args) == 1:
					Singleton.log_msg("No second argument.", Singleton.LogType.ERROR)
					return
				match args[1]:
					"t1":
						path = "res://scenes/levels/tutorial_1/tutorial_1_1.tscn"
					"t1r2":
						path = "res://scenes/levels/tutorial_1/tutorial_1_2.tscn"
					"t1r3":
						path = "res://scenes/levels/tutorial_1/tutorial_1_3.tscn"
					"t1r4":
						path = "res://scenes/levels/tutorial_1/tutorial_1_4.tscn"
					_:
						path = ""
				if path == "":
					Singleton.log_msg("Scene does not exist.", Singleton.LogType.ERROR)
				else:
					Singleton.set_location = null
					var err = Singleton.warp_to(path)
					if err == OK or err == null:
						Singleton.log_msg("Warped to " + path)
					else:
						Singleton.log_msg("Error: " + str(err), Singleton.LogType.ERROR)
			"scene":
				var scene = "res://" + args[1] + ".tscn"
				var file_check = File.new()
				if file_check.file_exists(scene):
					var err = Singleton.warp_to(scene)
					if err == OK:
						Singleton.log_msg("Warped to " + scene)
					else:
						Singleton.log_msg("Error: " + str(err), Singleton.LogType.ERROR)
				else:
					Singleton.log_msg("Scene does not exist.", Singleton.LogType.ERROR)
			"water":
				if args[1].to_lower() == "inf":
					Singleton.water = INF
					Singleton.log_msg("Water is now infinite.")
				else:
					Singleton.water = int(args[1])
					Singleton.log_msg("Water set to %d" % int(args[1]))
			"ref":
				Singleton.water = max(Singleton.water, 100)
				Singleton.log_msg("Water refilled.")
			"c":
				Singleton.classic = !Singleton.classic
				if Singleton.classic:
					Singleton.log_msg("Classic mode enabled.")
				else:
					Singleton.log_msg("Classic mode disabled.")
			"die":
				$"/root/Main/Player".take_damage(8)
				Singleton.log_msg("Dead.")
			"dmg":
				$"/root/Main/Player".take_damage(int(args[1]))
				Singleton.log_msg("Took %d damage." % int(args[1]))
			"fdmg":
				Singleton.hp -= int(args[1])
				Singleton.log_msg("Forced %d damage." % int(args[1]))
			"designer", "ld":
				Singleton.log_msg("Entered Level Designer.")
				# warning-ignore:RETURN_VALUE_DISCARDED
				get_tree().change_scene("res://level_designer/level_designer.tscn")
			"menu":
				Singleton.log_msg("Warped to menu.")
				# warning-ignore:RETURN_VALUE_DISCARDED
				get_tree().change_scene("res://scenes/title/menu.tscn")
			"title":
				Singleton.log_msg("Warped to title.")
				# warning-ignore:RETURN_VALUE_DISCARDED
				get_tree().change_scene("res://scenes/title/title.tscn")
			"vps":
				Singleton.log_msg("Entering VPS editor.")
				# warning-ignore:return_value_discarded
				get_tree().change_scene("res://scenes/menus/visual_pipescript/editor.tscn")
			"fludd":
				match args[1]:
					"h", "hover", "0":
						Singleton.collected_nozzles[0] = !Singleton.collected_nozzles[0]
						Singleton.log_msg("Toggled hover.")
					"r", "rocket", "1":
						Singleton.collected_nozzles[1] = !Singleton.collected_nozzles[1]
						Singleton.log_msg("Toggled rocket.")
					"t", "turbo", "2":
						Singleton.collected_nozzles[2] = !Singleton.collected_nozzles[2]
						Singleton.log_msg("Toggled turbo.")
					"all":
						Singleton.collected_nozzles = [true, true, true]
						Singleton.log_msg("All nozzles enabled.")
					"none":
						Singleton.collected_nozzles = [false, false, false]
						Singleton.log_msg("All nozzles disabled.")
			"cherry":
				var player = load("res://classes/player/player.tscn")
				var inst = player.instance()
				inst.position = $"/root/Main/Player".position + Vector2.UP * 64 + Vector2(rand_range(-16, 16), rand_range(-16, 16))
				$"/root/Main".add_child(inst)
			"locale":
				TranslationServer.set_locale(args[1])
				Singleton.log_msg("Locale set to \"%s\"." % args[1])
			"report":
				req.request("https://discord.com/api/webhooks/937358472788475934/YQppuK8SSgYv_v0pRosF3AWBufPiVZui2opq5msMKJ1h-fNhVKsvm3cBRhvHOZ9XqSad", ["Content-Type:application/json"], true, HTTPClient.METHOD_POST, to_json({"content": cmd.substr(7), "username": hook_name}))
			"rename":
				hook_name = cmd.substr(7)
				req.request("https://discord.com/api/webhooks/937358472788475934/YQppuK8SSgYv_v0pRosF3AWBufPiVZui2opq5msMKJ1h-fNhVKsvm3cBRhvHOZ9XqSad", ["Content-Type:application/json"], true, HTTPClient.METHOD_POST, to_json({"content":"renamed to \"" + hook_name + "\"", "username": hook_name}))
			_:
				Singleton.log_msg("Unknown command \"%s\"." % args[0], Singleton.LogType.ERROR)


func _process(_delta):
	if Input.is_action_just_pressed("debug"):
		visible = !visible
		get_tree().paused = visible
		Singleton.set_pause("console", visible)
		input_line.grab_focus()
		input_line.text = input_line.text.replace("/", "")
	if visible:
		if Input.is_action_just_pressed("ui_accept"):
			run_command(input_line.text)
			input_line.text = ""
		if Input.is_action_just_pressed("ui_up"):
			var size = history.size()
			if hist_index < history.size():
				input_line.text = history[size - hist_index - 1]
				hist_index += 1
	logger.margin_top = -24 - (Singleton.line_count + 1) * (logger.get_font("normal_font").get_height() + 1)
