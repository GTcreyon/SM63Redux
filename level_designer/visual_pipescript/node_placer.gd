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

func compile_to_source(start_piece):
	var queue = [start_piece]
	while !queue.empty():
		var piece = queue.pop_front()
		
		match piece.json_data.type:
			"if":
				var condition = get_unique_variable_name()
				source_code += "set %s $CONDITION$" % condition
				source_code += "if %s" % condition
				compile_to_source(piece.inner_connection)
				source_code += "end"
			"loop":
				var condition = get_unique_variable_name()
				var label = get_unique_variable_name()
				source_code += "set %s $CONDITION$" % condition
				source_code += "label %s" % label
				source_code += "if %s" % condition
				compile_to_source(piece.inner_connection)
				source_code += "goto %s" % label
				source_code += "end"
			_:
				print("Unknown piece ", piece.json_data.type)
		
		if piece.bottom_connection:
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
	pipescript.interpret("""
string-literal func_name foo
string-literal get_parent get_parent

gd-call-set parent self get_parent
gd-call self func_name parent
""")
	get_parent()
	pipescript.set_object_variable("self", get_node("Test1"))
	pipescript.execute()
