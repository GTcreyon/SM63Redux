extends ColorRect

onready var save_btn = $Save
onready var load_btn = $Load
onready var run_btn = $Run
onready var graph = $"../GraphEdit"
onready var place_btn = $"../Place"

func compile_graph():
	for node in place_btn.created_nodes.values():
		print(node)

func _on_Run_pressed():
	compile_graph()
