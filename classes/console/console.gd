extends Control

var history: PackedStringArray = []
var hist_index = 0
var req = HTTPRequest.new()
var hook_name = "Ingame Webhook"
var line_count: int = 0
var command_hints = [
	["help", "Displays the help menu"],
	["w", ["t1", "tutorial_1", "lobby"], "Wraps to a specific level"],
	["scene", "Changes the scene to a specific file (without the .tscn)"], # Idea: possible filesystem traversal? Although this seems a bit much for this PR.
	["water", ["inf", "<integer>"], "Sets the water level for your fludd (normal range 0-100 or infinite)"],
	["ref", "Refills your water"],
	["c", "Toggles classic mode"],
	["die", "Instantly kills the player"],
	["dmg", "<integer>", "Damages the player"],
	["fdmg", "<integer>", "Damages the player, ignoring any resistances"],
	["hit", "<integer>", "<1 or -1>", "Damages the player and shoves them into a direction"],
	[["hp", "health"], "<integer>", "Heals the player"],
	[["designer", "ld"], "Enters the level designer"],
	["menu", "Goes back to the menu"],
	["title", "Goes back to the title screen"],
	["vps", "Open the Visual PipeScript editor"],
	["fludd", ["none", "all", "t", "turbo", "2", "r", "rocket", "1", "h", "hover", "0"], "Change your currently equipped fludd"],
	["cherry", "Clone mario"],
	["locale", "Changes the language of the game"], # In _ready() all language options will be added
	["report", "<report...>", "Report a bug"],
	["rename", "<report...>", "Renames a bug report title"],
]
var selected_completion = {
	selected = false,
	query = "",
	option = ""
}

@onready var logger = $Logger
@onready var input_line = $Input
@onready var suggestions_log = $Suggestions

func get_autocompletion_for_command(cmd: String):
	for completion in command_hints:
		var matching = false
		if typeof(completion[0]) == TYPE_ARRAY:
			if completion[0].find(cmd) != -1:
				matching = true
		elif completion[0] == cmd:
			matching = true
		if matching:
			return completion


func _ready():
	var locale_completion = get_autocompletion_for_command("locale")
	var locales = TranslationServer.get_loaded_locales()
	locales.append("en_US")
	locale_completion.insert(1, locales)

	add_child(req)


func run_command(cmd: String):
	if cmd != "":
		hist_index = 0
		if cmd[0] == "/":
			cmd = cmd.substr(1)
		history.append(cmd)
		var args: PackedStringArray = cmd.split(" ")
		match args[0].to_lower():
			"help":
				for hint in command_hints:
					var command = hint[0]
					var formatted = ""
					if typeof(command) == TYPE_ARRAY:
						for option in command:
							formatted += option + ", "
						formatted = formatted.substr(0, len(formatted) - 2)
					else:
						formatted = command
					var description = hint[len(hint) - 1]
					#formatted += "\t\t\t" + description
					Singleton.log_msg("%-20s %s" % [formatted, description], Singleton.LogType.INFO)
			"w":
				var path
				if len(args) == 1:
					Singleton.log_msg("No second argument.", Singleton.LogType.ERROR)
					return
				match args[1]:
					"t1", "tutorial_1":
						if len(args) <= 2:
							path = "res://scenes/levels/tutorial_1/tutorial_1_1.tscn"
						else:
							path = "res://scenes/levels/tutorial_1/tutorial_1_" + args[2] + ".tscn"
					"lobby":
						path = "res://scenes/levels/castle/lobby/castle_lobby.tscn"
					_:
						path = ""
				var err = OK
				if path == "" or not ResourceLoader.exists(path):
					Singleton.log_msg("Scene does not exist.", Singleton.LogType.ERROR)
				else:
					Singleton.warp_location = null
					err = Singleton.warp_to(path, $"/root/Main/Player")
					if err == OK or err == null:
						Singleton.log_msg("Warped to " + path)
					else:
						Singleton.log_msg("Error: " + str(err), Singleton.LogType.ERROR)
			"scene":
				if len(args) == 1:
					Singleton.log_msg("No second argument.", Singleton.LogType.ERROR)
					return
				var scene = "res://" + args[1] + ".tscn"
				if FileAccess.file_exists(scene):
					var err = Singleton.warp_to(scene, $"/root/Main/Player")
					if err == OK:
						Singleton.log_msg("Warped to " + scene)
					else:
						Singleton.log_msg("Error: " + str(err), Singleton.LogType.ERROR)
				else:
					Singleton.log_msg("Scene does not exist.", Singleton.LogType.ERROR)
			"water":
				if len(args) == 1:
					Singleton.log_msg("No second argument.", Singleton.LogType.ERROR)
					return
				if args[1].to_lower() == "inf":
					$"/root/Main/Player".water = INF
					Singleton.log_msg("Water is now infinite.")
				else:
					$"/root/Main/Player".water = int(args[1])
					Singleton.log_msg("Water set to %d" % int(args[1]))
			"ref":
				var player = $"/root/Main/Player"
				player.water = max(player.water, 100)
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
				if len(args) == 1:
					Singleton.log_msg("No second argument.", Singleton.LogType.ERROR)
					return
				$"/root/Main/Player".take_damage(int(args[1]))
				Singleton.log_msg("Took %d damage." % int(args[1]))
			"fdmg":
				if len(args) == 1:
					Singleton.log_msg("No second argument.", Singleton.LogType.ERROR)
					return
				$"/root/Main/Player".hp -= int(args[1])
				Singleton.log_msg("Forced %d damage." % int(args[1]))
			"hit":
				if len(args) <= 2:
					Singleton.log_msg("No second argument.", Singleton.LogType.ERROR)
					return
				$"/root/Main/Player".take_damage_shove(int(args[1]), int(args[2]))
				Singleton.log_msg("Hit for %d damage." % int(args[1]))
			"hp", "health":
				if len(args) == 1:
					Singleton.log_msg("No second argument.", Singleton.LogType.ERROR)
					return
				var val = int(args[1])
				if args[1] != "0" and val == 0:
					Singleton.log_msg("Couldn't set HP to %s." % args[1], Singleton.LogType.ERROR)
				else:
					$"/root/Main/Player".hp = val
					Singleton.log_msg("Set HP to %d." % val)
			"designer", "ld":
				Singleton.log_msg("Entered Level Designer.")
				Singleton.prepare_exit_game()
				# warning-ignore:RETURN_VALUE_DISCARDED
				get_tree().change_scene_to_file("res://scenes/menus/level_designer/level_designer.tscn")
			"menu":
				Singleton.log_msg("Warped to menu.")
				Singleton.prepare_exit_game()
				# warning-ignore:RETURN_VALUE_DISCARDED
				get_tree().change_scene_to_file("res://scenes/menus/title/main_menu/main_menu.tscn")
			"title":
				Singleton.log_msg("Warped to title.")
				Singleton.prepare_exit_game()
				# warning-ignore:RETURN_VALUE_DISCARDED
				get_tree().change_scene_to_file("res://scenes/menus/title/title.tscn")
			"vps":
				Singleton.log_msg("Entering VPS editor.")
				# warning-ignore:return_value_discarded
				get_tree().change_scene_to_file("res://scenes/menus/visual_pipescript/editor.tscn")
			"fludd":
				if len(args) == 1:
					Singleton.log_msg("No second argument.", Singleton.LogType.ERROR)
					return
				var player = $"/root/Main/Player"
				match args[1]:
					"h", "hover", "0":
						player.collected_nozzles[0] = !player.collected_nozzles[0]
						Singleton.log_msg("Toggled hover.")
					"r", "rocket", "1":
						player.collected_nozzles[1] = !player.collected_nozzles[1]
						Singleton.log_msg("Toggled rocket.")
					"t", "turbo", "2":
						player.collected_nozzles[2] = !player.collected_nozzles[2]
						Singleton.log_msg("Toggled turbo.")
					"all":
						player.collected_nozzles = [true, true, true]
						Singleton.log_msg("All nozzles enabled.")
					"none":
						player.collected_nozzles = [false, false, false]
						Singleton.log_msg("All nozzles disabled.")
			"cherry":
				var player = load("res://classes/player/player.tscn")
				var inst = player.instantiate()
				inst.position = $"/root/Main/Player".position + Vector2.UP * 64 + Vector2(randf_range(-16, 16), randf_range(-16, 16))
				$"/root/Main".add_child(inst)
			"locale":
				if len(args) == 1:
					Singleton.log_msg("No second argument.", Singleton.LogType.ERROR)
					return
				TranslationServer.set_locale(args[1])
				Singleton.log_msg("Locale set to \"%s\"." % args[1])
			"report":
				req.request(
					"https://discord.com/api/webhooks/937358472788475934/YQppuK8SSgYv_v0pRosF3AWBufPiVZui2opq5msMKJ1h-fNhVKsvm3cBRhvHOZ9XqSad",
					["Content-Type:application/json"],
					HTTPClient.METHOD_POST,
					JSON.stringify({"content": cmd.substr(7), "username": hook_name})
					)
			"rename":
				hook_name = cmd.substr(7)
				req.request(
					"https://discord.com/api/webhooks/937358472788475934/YQppuK8SSgYv_v0pRosF3AWBufPiVZui2opq5msMKJ1h-fNhVKsvm3cBRhvHOZ9XqSad",
					["Content-Type:application/json"], 
					HTTPClient.METHOD_POST,
					JSON.stringify({"content":"renamed to \"" + hook_name + "\"", "username": hook_name})
					)
			_:
				Singleton.log_msg("Unknown command \"%s\"." % args[0], Singleton.LogType.ERROR)


func enable(enabled):
	visible = enabled
	get_tree().paused = visible
	Singleton.set_pause("console", visible)
	if visible:
		input_line.begin_new()


func _input(event):
	if event.is_action_pressed("debug") or event.is_action_pressed("altdebug"):
		enable(!visible)
		accept_event()
	
	if visible:
		if event.is_action_pressed("ui_accept"):
			if selected_completion.selected:
				var caret = input_line.caret_column
				var move_caret_by = len(selected_completion.option) - len(selected_completion.query) + 1
				input_line.text += selected_completion.option.substr(len(selected_completion.query)) + " "
				input_line.caret_column = caret + move_caret_by
				input_line.update_text()
			else:
				run_command(input_line.text.strip_edges())
				input_line.clear()
		
		if event.is_action_pressed("ui_up"):
			var hist_size = history.size()
			if hist_index < hist_size:
				input_line.text = history[hist_size - hist_index - 1]
				hist_index += 1
	logger.offset_top = -40 - (Singleton.line_count + 1) * (logger.get_theme_font("normal_font").get_height() + 1)

func display_completion(query: String, options: Array):
	suggestions_log.clear()
	
	var sorted_options = []
	for option in options:
		if option.begins_with(query):
			sorted_options.append(option)
	
	# Set the current selected completion to the first one on the list
	selected_completion.selected = len(query) > 0 and len(sorted_options) > 0
	if selected_completion.selected:
		selected_completion.query = query
		selected_completion.option = sorted_options[0]
	
	sorted_options.sort()
	for option in options:
		if !option.begins_with(query):
			sorted_options.append(option)
	
	for option in sorted_options:
		if option.begins_with(query):
			suggestions_log.push_color(Color.AQUA)
			suggestions_log.add_text(query)
			suggestions_log.pop()
			suggestions_log.add_text(option.substr(len(query)) + " ")
		else:
			suggestions_log.add_text(option + " ")


func _on_Input_text_changed(text: String):
	# Did the user even begin typing OR is the user at the first word?
	# If not, return a list of commands
	var words = text.split(" ", false)
	# Without this check, it lingers on the previous completion until we type something
	if text.ends_with(" "):
		words.append("")
	
	var word_count = len(words)
	if word_count <= 1:
		var suggestions = []
		for hint in command_hints:
			if typeof(hint[0]) == TYPE_STRING:
				suggestions.append(hint[0])
			else:
				suggestions.append_array(hint[0])
		if word_count == 0:
			words.append("")
		display_completion(words[0], suggestions)
		return
	# Is what the user typed valid?
	# If not, return nothing
	var completion = get_autocompletion_for_command(words[0])
	if completion == null:
		display_completion(text, [])
		return
	var words_in_completion = len(completion) - 1 # Ignore the description
	
	# Is the user trying to provide more arguments than there are?
	if word_count > words_in_completion:
		display_completion("", [])
	else:
		var this_completion = completion[word_count - 1]
		var suggestions = []
		if typeof(this_completion) == TYPE_STRING:
			display_completion(words[word_count - 1], [this_completion])
			return
		for suggestion in this_completion:
			suggestions.append(suggestion)
		display_completion(words[word_count - 1], suggestions)
