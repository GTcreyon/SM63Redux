extends NinePatchRect

onready var properties = $Properties
onready var title = $Title

func set_title(text):
	title.text = text
	fit_to_children()

func add_connector(label):
	fit_to_children()

func add_label(label):
	var node = Label.new()
	node.text = label
	node.align = Label.ALIGN_CENTER
	node.valign = Label.VALIGN_CENTER
	node.rect_min_size.y = 20
	node.modulate = Color.black
	properties.add_child(node)
	fit_to_children()

func add_field(placeholder, value = ""):
	var node = LineEdit.new()
	node.text = value
	node.placeholder_text = placeholder
	node.align = Label.ALIGN_CENTER
	node.rect_min_size.y = 20
#	node.modulate = Color.black
	properties.add_child(node)
	fit_to_children()

func fit_to_children():
	var max_size_x = title.rect_size.x
	for property in properties.get_children():
		max_size_x = max(max_size_x, property.rect_size.x)
	rect_size = Vector2(
		max_size_x,
		20 * len(properties.get_children()) + 30
	)
