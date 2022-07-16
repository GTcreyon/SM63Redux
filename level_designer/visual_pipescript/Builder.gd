extends ColorRect

onready var save_btn = $Save
onready var load_btn = $Load
onready var run_btn = $Run
onready var place_btn = $"../Place"
onready var graph = $"../GraphEdit"

var to_connections

func get_connections_to(node_name):
	var connections = []
	for data in graph.get_connection_list():
		if data.to == node_name && data.from_port != 0:
			connections.append(data)
	return connections

func get_dict_key_from_idx(dict, target):
	var idx = 0
	for key in dict:
		if idx == target:
			return key
		idx += 1

func compile_graph():
	to_connections = {}
	
	# first organise the data in a practical way
	for data in graph.get_connection_list():
		# we're not making an array since
		if data.to_port == 0:
			to_connections[data.to] = {
				name = data.to,
				type = graph.get_node(data.to).title,
				next = data.to,
				data = {}
			}
	# this is O(n^2), there's ways not to make it like this, I'm sure, but can't wrap my head around it now
	for node in to_connections.values():
		var offset = 1
		var connections = get_connections_to(node.name)
		for connection in connections:
			# handle inputs
			if connection.to == node.name:
				var slot_idx = connection.to_port - offset
				var key = get_dict_key_from_idx(
					place_btn.nodes_dict[node.type].slots,
					slot_idx
				)
				
				print(node.type)
				print("--> ", key)
	

func _on_Run_pressed():
	compile_graph()
