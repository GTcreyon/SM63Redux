extends Node

onready var graph = $Graph
onready var camera := $Camera
onready var selection_container = $CanvasLayer/Theme/SelectionMenu/VBox
onready var compiler = $PipeScript/VisualCompiler
onready var piece_instances = {
	holster = preload("res://level_designer/visual_pipescript/vps_holster_piece.tscn"),
	normal = preload("res://level_designer/visual_pipescript/vps_piece.tscn"),
	begin = preload("res://level_designer/visual_pipescript/vps_begin.tscn")
}

var pieces

func drag_begin(piece):
	var instance: NinePatchRect = piece_instances[piece.display].instance()
	instance.setup(piece)
	instance.creation_drag = true
	graph.add_child(instance)
	return instance

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
	compiler.compile(true, true)
