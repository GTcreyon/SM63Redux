extends Node

const PHANTOM_STYLE = preload("res://scenes/menus/visual_pipescript/phantom_style.tres")
const BYLIGHT = preload("res://fonts/bylight/bylight.tres")
const EDITOR_THEME = preload("res://scenes/menus/visual_pipescript/visual_editor_theme.tres")

onready var graph = $Graph
onready var camera := $Camera
onready var selection_container = $CanvasLayer/Theme/SelectionMenu/VBox
onready var compiler = $PipeScript/VisualCompiler
onready var piece_instances = {
	holster = preload("res://scenes/menus/visual_pipescript/vps_holster_piece.tscn"),
	normal = preload("res://scenes/menus/visual_pipescript/vps_piece.tscn"),
	begin = preload("res://scenes/menus/visual_pipescript/vps_begin.tscn")
}

var pieces

# Phantom setup
var selected_node = null setget set_selected_node
var selected_index = -1 setget set_selected_index

var phantom_line_edit = LineEdit.new()
var phantom_possible_items = Panel.new()
var phantom_possible_pieces = []
var phantom_selected_option = 0

func set_selected_node(new):
	selected_node = new
	# If there's an error, we modulate the color, we make that modulation go away when we select it
	if selected_node:
		selected_node.modulate = Color(1, 1, 1)
	
	handle_phantom_node()

func set_selected_index(new):
	selected_index = new
	if selected_node && selected_index >= 0 && selected_index < len(selected_node.line_edits):
		selected_node.line_edits[selected_index].grab_focus()
	# If there's an error, we modulate the color, we make that modulation go away when we select it
	if selected_node:
		selected_node.modulate = Color(1, 1, 1)
	handle_phantom_node()

func get_text_width(text: String) -> float:
	var width = 0
	for c in text:
		width += BYLIGHT.get_char_size(c as int).x
	return width

func phantom_text_entered(text):
	if !phantom_possible_items.visible || phantom_possible_items.get_child_count() <= phantom_selected_option:
		return
	
	var selected = phantom_possible_pieces[phantom_selected_option]
	if !selected:
		return
	
	var instance: NinePatchRect = piece_instances[selected.display].instance()
	instance.setup(selected)
	instance.rect_global_position = selected_node.rect_global_position + Vector2(
		0 if selected_index == -1 else 20,
		selected_node.rect_size.y if selected_index == -1 else 26
	)
	graph.add_child(instance)
	var connection = instance.snap_to_others()
	if connection:
		connection[0][connection[1]] = instance
		instance.set_top_connection(connection[0])
	set_selected_node(instance)
	if len(instance.line_edits) > 0:
		set_selected_index(0)

func phantom_text_change(text):
	phantom_possible_pieces = []
	if len(text) == 0:
		phantom_possible_items.visible = false
		return
	
	# Make sure we don't have leftovers
	for child in phantom_possible_items.get_children():
		child.queue_free()
	
	# Whenever the text changes, reset the pointer to 0
	phantom_selected_option = 0
	
	var pos_y = 4
	for piece in pieces:
		var display_name = piece["display-name"]
		if display_name.to_lower().begins_with(text.to_lower()):
			# Make sure we trim the string so we don't have that annoying autowrap with richtextlabels
			# As for why we do +60, I HAVE NO CLUE, get_text_width() doesn't as this wierd offset
			var check_width = phantom_line_edit.rect_size.x - 6 + 100
			var real_text = text
			while get_text_width(real_text) > check_width:
				real_text = real_text.left(len(real_text) - 1)
			var real_display = display_name.substr(len(text))
			while get_text_width(real_text + real_display) > check_width:
				real_display = real_display.left(len(real_display) - 1)
			
			# Create the actual richtextlabel
			var label = RichTextLabel.new()
			label.bbcode_enabled = true
			label.bbcode_text = "[color=#0088ff]%s[/color]%s" % [real_text, real_display]
			label.rect_position = Vector2(3, pos_y)
			label.rect_size.x = phantom_line_edit.rect_size.x - 6
			label.rect_size.y = BYLIGHT.get_height() + 2
			label.fit_content_height = true
			label.scroll_active = false
			label.add_font_override("font", BYLIGHT)
			# Make sure the first option is colored slightly darker as it is selected
			if pos_y == 4:
				label.modulate = Color(0.8, 0.8, 0.8)
			phantom_possible_items.add_child(label)
			phantom_possible_pieces.append(piece)
			pos_y += label.rect_size.y + 4
	
	phantom_possible_items.rect_size = Vector2(phantom_line_edit.rect_size.x, pos_y)
	phantom_possible_items.rect_global_position = phantom_line_edit.rect_global_position + Vector2(0, phantom_line_edit.rect_size.y + 4)
	phantom_possible_items.visible = true
	

# Handle keyboard inputs
func _input(event):
	if event is InputEventKey:
		# The up & down keys are being used to scroll through possible options
		if event.is_action_pressed("vps_select_up") && phantom_possible_items.get_child_count() > phantom_selected_option:
			phantom_possible_items.get_child(phantom_selected_option).modulate = Color(1, 1, 1)
			phantom_selected_option = max(phantom_selected_option - 1, 0)
			phantom_possible_items.get_child(phantom_selected_option).modulate = Color(0.8, 0.8, 0.8)
		elif event.is_action_pressed("vps_select_down") && phantom_possible_items.get_child_count() > phantom_selected_option:
			phantom_possible_items.get_child(phantom_selected_option).modulate = Color(1, 1, 1)
			phantom_selected_option = min(phantom_selected_option + 1, phantom_possible_items.get_child_count() - 1)
			phantom_possible_items.get_child(phantom_selected_option).modulate = Color(0.8, 0.8, 0.8)
		elif event.is_action_pressed("vps_cancel_selection"):
			# If we press escape, stop!
			set_selected_node(null)

# This handles creating nodes via name-searching
func handle_phantom_node():
	if phantom_line_edit:
		phantom_possible_items.visible = false
		phantom_line_edit.visible = false
	if selected_index < 0 && selected_node:
		phantom_line_edit.text = ""
		phantom_line_edit.visible = true
		phantom_line_edit.rect_global_position = selected_node.rect_global_position + Vector2(
			(0 if selected_index == -1 else 20) + 2,
			(selected_node.rect_size.y if selected_index == -1 else 26) + 2
		)
		phantom_line_edit.rect_size.x = selected_node.rect_size.x
		phantom_line_edit.grab_focus()
		phantom_possible_items.rect_global_position = phantom_line_edit.rect_global_position + Vector2(0, phantom_line_edit.rect_size.y + 4)

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
				item.focus_mode = Control.FOCUS_NONE
				item.connect("button_down", self, "drag_begin", [piece])
				selection_container.add_child(item)

func _ready():
	# Get the nodes from our nodes file
	var file = File.new()
	file.open("res://scenes/menus/visual_pipescript/pieces.json", File.READ)
	var content = file.get_as_text()
	file.close()
	pieces = parse_json(content)
	# Add the buttons
	add_buttons()
	
	# Keyboard shortcuts
	phantom_line_edit.visible = false
	phantom_line_edit.add_font_override("font", BYLIGHT)
	phantom_line_edit.add_stylebox_override("normal", PHANTOM_STYLE)
	phantom_line_edit.add_stylebox_override("focus", PHANTOM_STYLE)
	phantom_line_edit.connect("text_changed", self, "phantom_text_change")
	phantom_line_edit.connect("text_entered", self, "phantom_text_entered")
	add_child(phantom_line_edit)
	
	phantom_possible_items.theme = EDITOR_THEME
	add_child(phantom_possible_items)

func _on_Run_pressed():
	compiler.compile(true, true)
