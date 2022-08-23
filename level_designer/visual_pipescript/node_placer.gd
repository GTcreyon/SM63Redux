extends Node

const PHANTOM_STYLE = preload("res://level_designer/visual_pipescript/phantom_style.tres")
const BYLIGHT = preload("res://fonts/bylight/bylight.tres")

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

# Phantom setup
var selected_node = null setget set_selected_node
var selected_index = -1 setget set_selected_index

var phantom_line_edit

func set_selected_node(new):
	selected_node = new
	handle_phantom_node()

func set_selected_index(new):
	selected_index = new
	handle_phantom_node()

# This handles creating nodes via name-searching
func handle_phantom_node():
	if phantom_line_edit:
		phantom_line_edit.queue_free()
		phantom_line_edit = null
	if selected_index < 0 && selected_node:
		phantom_line_edit = LineEdit.new()
		phantom_line_edit.add_font_override("font", BYLIGHT)
		phantom_line_edit.add_stylebox_override("normal", PHANTOM_STYLE)
		phantom_line_edit.add_stylebox_override("focus", PHANTOM_STYLE)
		phantom_line_edit.rect_global_position = selected_node.rect_global_position + Vector2(
			(0 if selected_index == -1 else 20) + 2,
			(selected_node.rect_size.y if selected_index == -1 else 26) + 2
		)
		phantom_line_edit.rect_size.x = selected_node.rect_size.x
		add_child(phantom_line_edit)
		phantom_line_edit.grab_focus()

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
