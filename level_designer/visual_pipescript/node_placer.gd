extends Node

onready var graph = $Graph
onready var camera := $Camera
onready var selection_container = $CanvasLayer/Theme/SelectionMenu/VBox
onready var pipescript = $PipeScript
onready var piece_instances = {
	holster = preload("res://level_designer/visual_pipescript/vps_holster_piece.tscn"),
	normal = preload("res://level_designer/visual_pipescript/vps_piece.tscn"),
	begin = preload("res://level_designer/visual_pipescript/vps_begin.tscn")
}

var pieces
var source_code = ""

var is_being_held_down = null

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

#func _input(event):
#	if event is InputEventMouseMotion && is_being_held_down:
#		is_being_held_down.rect_position = event.position + camera.position
#	if event.is_action_released("ld_place") && is_being_held_down:
#		is_being_held_down = null

func drag_begin(piece):
	var instance: NinePatchRect = piece_instances[piece.display].instance()
	instance.setup(piece)
	instance.creation_drag = true
	graph.add_child(instance)
#	is_being_held_down = instance

func add_buttons():
	var categories = [
		"Flow",
		"Maths",
		"Objects",
		"Advanced"
	]
	
	for category in categories:
		var heading = Label.new()
		heading.align = Label.ALIGN_CENTER
		heading.text = category
		selection_container.add_child(heading)
		for piece in pieces:
			if piece.category == category:
				var item = Button.new()
				item.text = piece["display-name"]
				item.align = Button.ALIGN_RIGHT
				item.connect("button_down", self, "drag_begin", [piece])
				selection_container.add_child(item)

func _ready():
	# get the nodes from our nodes file
	var file = File.new()
	file.open("res://level_designer/visual_pipescript/pieces.json", File.READ)
	var content = file.get_as_text()
	file.close()
	pieces = parse_json(content)
	# add the buttons
	add_buttons()

func _on_Run_pressed():
		# Make sure to empty the code holder
	source_code = ""
	
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
		pipescript.interpret(source_code)
		pipescript.set_object_variable("self", get_parent().get_child(1).get_child(0))
		pipescript.execute()
		
