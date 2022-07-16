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
	var node = GraphNode.new()
	node.title = target
	
	# control flow
	var slot_idx = 0
	var flow = Label.new()
	flow.text = " Program Flow "
	node.add_child(flow)
	node.set_slot(
		slot_idx,
		node_data.flow.input, 0, Color(0, 0, 1),
		node_data.flow.output, 0, Color(0, 0, 1)
	)
	slot_idx += 1
	
	# add the attributes
	for slot in node_data.attributes.values():
		var type = node_types[slot.type]
		var control = type.create.new()
		if control is Label:
			control.text = slot.label
		elif control is LineEdit:
			control.placeholder_text = slot.label
			control.text = slot.value
		node.add_child(control)
		node.set_slot_enabled_left(slot_idx, false)
		node.set_slot_enabled_right(slot_idx, false)
		slot_idx += 1
	
	# add connectors
	for slot in node_data.slots.values():
		var type = node_types[slot.type]
		var control = type.create.new()
		if control is Label:
			control.text = slot.label
		elif control is LineEdit:
			control.placeholder_text = slot.label
			control.text = slot.value
		node.add_child(control)
		node.set_slot(
			slot_idx,
			slot.input, type.type, type.color,
			slot.output, type.type, type.color
		)
		slot_idx += 1
	
	node.offset = graph.get_local_mouse_position() + graph.scroll_offset
	graph.add_child(node)
	
	text = default_text
	visible = false

# code below copied from:
# https://gdscript.com/solutions/godot-graphnode-and-graphedit-tutorial/

#TODO: make sure only 1 connection can be made
func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	graph.connect_node(from, from_slot, to, to_slot)

func remove_connections_to_node(node):
	for con in graph.get_connection_list():
		if con.to == node.name or con.from == node.name:
			graph.disconnect_node(con.from, con.from_port, con.to, con.to_port)

func _on_GraphEdit_delete_nodes_request():
	for node in selected_nodes.keys():
		if selected_nodes[node]:
			remove_connections_to_node(node)
			node.queue_free()
	selected_nodes = {}

func _on_GraphEdit_node_selected(node):
	selected_nodes[node] = true

func _on_GraphEdit_node_unselected(node):
	selected_nodes[node] = false

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	graph.disconnect_node(from, from_slot, to, to_slot)
