extends Node

onready var pipescript = $".."
onready var graph = $"/root/Main/Graph"

onready var test = $"/root/Main/CanvasLayer/Theme/Titlebar/Run"

var source_code = ""
var error_flagged = false
var node_which_flagged = null

var id = 0
func get_unique_variable_name():
	id += 1
	return "auto_variable#%d" % id

func add_line(txt, prefix):
	source_code += prefix + txt + "\n"

# Note: this is a recursive function, so there is a limit how many
# inner loops one can create but I doubt the limit will ever come into play.
func compile_to_source(start_piece, prefix = ""):
	# Make sure we are being sent valid data lol
	if !start_piece:
		return
	
	# Queue up all pieces we should compile
	var queue = [start_piece]
	while !queue.empty():
		var piece = queue.pop_front()
		
		# Make sure to cancel compilation if we reached an error
		if error_flagged:
			return
		
		# We first match the category then we match the type
		# This is done for no other reason besides organisational purposes
		match piece.json_data.category.to_lower():
			"flow":
				match piece.json_data.type:
					"start":
						pass
					"exit":
						add_line("exit!", prefix)
					"if":
						var condition = get_unique_variable_name()
						add_line("calc %s %s" % [condition, piece.get_input_text(0)], prefix)
						add_line("if %s\n" % condition, prefix)
						compile_to_source(piece.inner_connection, prefix + "\t")
						add_line("end", prefix)
					"loop":
						var condition = get_unique_variable_name()
						var label = get_unique_variable_name()
						add_line("label %s" % label, prefix)
						add_line("calc %s %s" % [condition, piece.get_input_text(0)], prefix)
						add_line("if %s" % condition, prefix)
						compile_to_source(piece.inner_connection, prefix + "\t")
						add_line("goto %s" % label, prefix)
						add_line("end", prefix)
					"function":
						add_line("function %s" % piece.get_input_text(0), prefix)
						compile_to_source(piece.bottom_connection, prefix + "\t")
						add_line("return", prefix)
						return # We force exit here, this is to prevent it from copy & pasting the same code twice
					"call":
						add_line("call %s" % piece.get_input_text(0), prefix)
			"maths":
				match piece.json_data.type:
					"set":
						add_line("calc %s %s" % [piece.get_input_text(0), piece.get_input_text(1)], prefix)
					"create-vector":
						var var_name = piece.get_input_text(0)
						add_line("gd-vec2-new %s %s %s" % [var_name, piece.get_input_text(1), piece.get_input_text(2)], prefix)
						add_line("gd-vec2-get %s %s x.S" % [var_name + ".x", var_name], prefix)
						add_line("gd-vec2-get %s %s y.S" % [var_name + ".y", var_name], prefix)
					"unwrap-vector":
						var var_name = piece.get_input_text(0)
						add_line("gd-vec2-get %s %s x.S" % [var_name + ".x", var_name], prefix)
						add_line("gd-vec2-get %s %s y.S" % [var_name + ".y", var_name], prefix)
					"update-vector":
						var var_name = piece.get_input_text(0)
						add_line("gd-vec2-set %s %s x.S" % [var_name + ".x", var_name], prefix)
						add_line("gd-vec2-set %s %s y.S" % [var_name + ".y", var_name], prefix)
					"print":
						add_line("print %s" % piece.get_input_text(0), prefix)
			"objects":
				pass
			"advances":
				match piece.json_data.type:
					"gd-call":
						var args = []
						for editor in piece.line_edits:
							if editor.text.empty():
								printerr("%s is not filled in!" % name)
							args.append(editor.text)
						add_line(
							("gd-call" + " %s".repeat(len(args))) % args,
							prefix
						)
					"gd-call-return":
						var args = [
							piece.get_input_text(2),
							piece.get_input_text(0),
							piece.get_input_text(1)
						]
						for editor_idx in len(piece.line_edits):
							if editor_idx < 3:
								continue
							var editor = piece.line_edits[editor_idx]
							if editor.text.empty():
								printerr("%s is not filled in!" % name)
							args.append(editor.text)
						add_line(
							("gd-call-set" + " %s".repeat(len(args))) % args,
							prefix
						)
			_:
				printerr("Unknown piece ", piece.json_data.type)
		
		if piece.bottom_connection != null:
			queue.append(piece.bottom_connection)

func compile(debug = false, print_source = false):
	# Make sure to empty the code holder
	source_code = "" if not debug else "debug-cmds\n"
	error_flagged = false
	node_which_flagged = null
	
	# First compile functions
	for node in graph.get_children():
		if node.json_data.type == "function":
			compile_to_source(node)
	
	# Find a starter node
	var start_node
	for node in graph.get_children():
		if node.json_data.type == "start":
			start_node = node
			break
	
	# If we found a starters node, then compile from there too
	if start_node:
		compile_to_source(start_node)
		# Error handling
		if error_flagged:
			printerr("VisualPipeScript Error:\n%s\nNode which flagged:\n%s" % [error_flagged, node_which_flagged])
			if node_which_flagged:
				node_which_flagged.modulate = Color(1, .4, .4)
			return
		if print_source:
			print(source_code)
		pipescript.interpret(source_code)
		pipescript.set_object_variable("self", test)
		pipescript.execute()
