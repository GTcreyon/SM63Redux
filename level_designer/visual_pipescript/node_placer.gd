extends OptionButton

onready var graph = $"../GraphEdit"

var default_text = "Place Node"
var selected_nodes = {}
var nodes
var nodes_dict

var node_types = {
	connector = {
		create = Label,
		color = Color(0, 0.5, 0.7),
		type = 1
	},
	variable = {
		create = LineEdit,
		color = Color(1, 1, 1),
		type = 2
	},
	equation = {
		create = LineEdit,
		color = Color(1, 1, 1),
		type = 3
	}
}

func get_node_data(node):
	for looping in nodes:
		if looping.name == node:
			return looping

func _input(event):
	if event.is_action_pressed("ld_alt_click"):
		visible = true
		set_position(event.position)

func add_buttons():
	add_item("Close")
	for node in nodes:
		add_item(node.name)
	text = default_text

func _ready():
	# get the nodes from our nodes file
	var file = File.new()
	file.open("res://level_designer/visual_pipescript/nodes.json", File.READ)
	var content = file.get_as_text()
	file.close()
	nodes = parse_json(content)
	nodes_dict = {}
	for node in nodes:
		nodes_dict[node.name] = node
	# add the buttons
	add_buttons()

func _on_Place_item_selected(index):
	var target = get_item_text(index)
	if target == "Close":
		text = default_text
		visible = false
		return
	
	var node_data = nodes[index - 1]
	print("pressed: ", get_item_text(index))
