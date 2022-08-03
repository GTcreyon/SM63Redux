extends OptionButton

onready var graph = $"../Graph"

onready var piece_instances = {
	holster = preload("res://level_designer/visual_pipescript/vps_holster_piece.tscn"),
	normal = preload("res://level_designer/visual_pipescript/vps_piece.tscn"),
	begin = preload("res://level_designer/visual_pipescript/vps_begin.tscn")
}

var pieces

func compile():
	pass

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
