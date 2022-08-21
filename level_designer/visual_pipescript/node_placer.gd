extends OptionButton

onready var graph = $"../Graph"
onready var pipescript = $"../PipeScript"
onready var piece_instances = {
	holster = preload("res://level_designer/visual_pipescript/vps_holster_piece.tscn"),
	normal = preload("res://level_designer/visual_pipescript/vps_piece.tscn"),
	begin = preload("res://level_designer/visual_pipescript/vps_begin.tscn")
}

var pieces
var source_code = ""

var id = 0
func get_unique_variable_name():
	id += 1
	return "UNIQUE_VAR#%d#" % id

func add_line(txt, prefix):
	source_code += prefix + txt + "\n"

func compile_to_source(start_piece, prefix = ""):
	if !start_piece:
		return
	
	var queue = [start_piece]
	while !queue.empty():
		var piece = queue.pop_front()
		
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
			"function":
				add_line("function %s" % piece.get_input_text(0), prefix)
				compile_to_source(piece.bottom_connection, prefix + "\t")
				add_line("return", prefix)
			"call":
				add_line("call %s" % piece.get_input_text(0), prefix)
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

func compile():
	# First find the start piece
	var start_piece
	for piece in graph.get_children():
		if piece.json_data.type == "start":
			start_piece = piece
			break
	compile_to_source(start_piece)
	

func _input(event):
	if event.is_action_pressed("ld_alt_click"):
		visible = true
		set_position(event.position)

func add_buttons():
	add_item("Close")
	for piece in pieces:
		add_item(piece.segments)
	text = "Close"

func _ready():
	# get the nodes from our nodes file
	var file = File.new()
	file.open("res://level_designer/visual_pipescript/pieces.json", File.READ)
	var content = file.get_as_text()
	file.close()
	pieces = parse_json(content)
	# add the buttons
	add_buttons()

func _on_Place_item_selected(index):
	var target = get_item_text(index)
	if target == "Close":
		text = "Close"
		visible = false
		select(0)
		return
	
	var piece_json_data = pieces[index - 1]
	var instance: NinePatchRect = piece_instances[piece_json_data.display].instance()
	graph.add_child(instance)
	
	instance.setup(piece_json_data)
	instance.rect_global_position = rect_global_position
#	instance.rect_size = Vector2(50, 50)
	
	# Close the menu
	text = "Close"
	visible = false
	select(0)

func test_call(arg):
	print("Yoo called from rust: ", arg)

func _on_Run_pressed():
		# Make sure to empty the code holder
	source_code = "debug-cmds\n"
	
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
		print("-- SRC --")
		print(source_code)
		print("--     --")
		pipescript.interpret(source_code)
		pipescript.set_object_variable("self", get_parent().get_child(1).get_child(0))
		pipescript.execute()
		
#	pipescript.interpret("""
#debug-cmds
#gd-call-set parent self get_parent.S
#gd-call self foo.S parent
#
#gd-call-set new_pos button get_position.S
#gd-vec2-get new_pos_x new_pos x.S
#add new_pos_x new_pos_x 20
#gd-vec2-set new_pos_x new_pos x.S
#gd-call button set_position.S new_pos
#""")
#	pipescript.set_object_variable("button", get_parent().get_child(1).get_child(0))
#	pipescript.execute()
