extends NinePatchRect

@onready var node_placer = $"/root/Main"
@onready var compiler = $"/root/Main/PipeScript/VisualCompiler"
@onready var graph = get_parent()

const BYLIGHT = preload("res://fonts/bylight/bylight.tres")
const STYLEBOX = preload("res://scenes/menus/visual_pipescript/line_edit_style.stylebox")
const EDITOR_THEME = preload("res://scenes/menus/visual_pipescript/visual_editor_theme.tres")

# Anchor points
var piece_anchor_points = {
	holster = {
		top_connection = Vector2(30, 4),
		inner_connection = Vector2(49, 25),
		bottom_connection = Vector2(30, -1)
	},
	normal = {
		top_connection = Vector2(30, 4),
		inner_connection = Vector2.INF,
		bottom_connection = Vector2(30, -1)
	},
	begin = {
		top_connection = Vector2.INF,
		inner_connection = Vector2.INF,
		bottom_connection = Vector2(30, -1)
	}
}

# Connection places
# Do NOT manually set top_connection, invoke the set_top_connection function for that
var top_connection : set = set_top_connection
var inner_connection
var bottom_connection

var being_dragged = false
var creation_drag = false
var holster_size_y = 0
var json_data

var line_edits = []

func validate_varname(word, should_flag = true):
	for c in word.to_lower():
		if !(c in "abcdefghijklmnopqrstuvwxyz_."):
			if should_flag:
				compiler.error_flagged = "%s is not a valid variable name! At %s" % [word, json_data["display-name"]]
				compiler.node_which_flagged = self
			return false
	return true


func get_input_text(idx):
	# TODO: Make to validate user data, you can do this by
	# reading the tags inside of segments in pieces.json
	# and then checking if it's valid or not
	if line_edits[idx]:
		var text = line_edits[idx].text
		if text.is_empty():
			compiler.error_flagged = "Input field is empty for %s" % json_data["display-name"]
			compiler.node_which_flagged = self
		
		# Validation
		var edit_type = line_edits[idx].placeholder_text
		match edit_type:
			"expression":
				pass
			"function_name":
				validate_varname(text)
				# Strings must be postfixed with .S
				text += ".S"
			"label":
				validate_varname(text)
			"single":
				if !text.is_valid_float() || !validate_varname(text):
					compiler.error_flagged = "Input field type 'single' is not a number nor variable. At %s" % json_data["display-name"]
					compiler.node_which_flagged = self
		if edit_type.begins_with("[") && edit_type.ends_with("]"):
			# Check if the inputted text is a valid substring
			var words = edit_type.substr(1, edit_type.length() - 2).split("|", false)
			var success = false
			for word in words:
				if word == text:
					success = true
			if !success:
				compiler.error_flagged = "%s is not a valid input! At %s" % [text, json_data["display-name"]]
				compiler.node_which_flagged = self
			# Strings must be postfixed with .S
			text += ".S"
		
		print(">>> ", text)
		return text
	printerr("%s does not have index %s." % [name, idx])

# Make sure that when we get added to a holster piece, we notify that it should increase it's size
func set_top_connection(conn):
	# Make sure top_connection is a valid piece
	if conn:
		top_connection = conn
	var piece = self.top_connection
	while piece:
		piece.update_to_fit_pieces()
		piece = piece.top_connection
	# Now we set it to the true value
	top_connection = conn

# This function resizes the block to fit the pieces within it, only call for holster pieces.
func update_to_fit_pieces():
	if json_data.display != "holster":
		return
	var original_size = size.y
	size.y = holster_size_y
	var piece = self.inner_connection
	while piece:
		size.y += piece.size.y
		piece = piece.bottom_connection
	if bottom_connection:
		bottom_connection.move_piece(
			bottom_connection.global_position + Vector2(0, size.y - original_size)
		)

func get_anchor_position(type: String) -> Vector2:
	match type:
		"bottom_connection":
			return global_position + Vector2(0, size.y) + piece_anchor_points[json_data.display][type]
		_:
			return global_position + piece_anchor_points[json_data.display][type]

func get_text_width(text: String) -> Vector2:
	var width = 0
	for c in text:
		if c != " ":
			width += BYLIGHT.get_char_size(c as int).x
	return Vector2(width, BYLIGHT.get_height())

# Make sure the node_placer knows which node is currently selected
func focus_changed(is_focus, index):
	if is_focus:
		node_placer.selected_node = self
		node_placer.selected_index = index

# Handle switching focus on enter
func text_submitted(_text, index):
	if index + 1 < len(line_edits):
		line_edits[index + 1].grab_focus()
	else:
		node_placer.selected_node = self
		node_placer.selected_index = -2 if json_data.display == "holster" else -1

# This gets called whenever the user pressed on "+" on function arguments
func add_input_field_on_press(button, field_text):
	var text_size = get_text_width(field_text)
	var label = LineEdit.new()
	label.add_theme_font_override("font", BYLIGHT)
	label.add_theme_stylebox_override("normal", STYLEBOX)
	label.placeholder_text = field_text
	label.size = text_size - Vector2(8, 0)
	label.position = Vector2(button.position.x, 4)
	label.connect("focus_entered", Callable(self, "focus_changed").bind(true, len(line_edits)))
	label.connect("focus_exited", Callable(self, "focus_changed").bind(false, len(line_edits)))
	label.connect("text_submitted", Callable(self, "text_submitted").bind(len(line_edits)))
	add_child(label)
	line_edits.append(label)
	button.position.x += text_size.x
	size.x += text_size.x

# Call this to configure the node with json_data
# Do not call twice on a node
func setup(data):
	focus_mode = Control.FOCUS_NONE
	
	line_edits = []
	json_data = data
	# Create the labels within the block
	var segments = data.segments.split(" ", false)
	var x_position = 0
	for segment in segments:
		var text_size = get_text_width(segment)
		if segment.begins_with("$+"):
			var button = Button.new()
			button.add_theme_font_override("font", BYLIGHT)
			button.add_theme_stylebox_override("normal", STYLEBOX)
			button.text = "+"
			text_size = get_text_width(button.text)
			button.align = Button.ALIGNMENT_CENTER
			button.position = Vector2(x_position, 4)
			button.connect("pressed", Callable(self, "add_input_field_on_press").bind(button, segment.substr(2)))
			add_child(button)
		elif segment.begins_with("$"):
			var label = LineEdit.new()
			label.add_theme_font_override("font", BYLIGHT)
			label.add_theme_stylebox_override("normal", STYLEBOX)
			label.placeholder_text = segment.substr(1)
			label.size = text_size + Vector2(-8, 0)
			label.position = Vector2(x_position, 4)
			label.connect("focus_entered", Callable(self, "focus_changed").bind(true, len(line_edits)))
			label.connect("focus_exited", Callable(self, "focus_changed").bind(false, len(line_edits)))
			label.connect("text_submitted", Callable(self, "text_submitted").bind(len(line_edits)))
			add_child(label)
			line_edits.append(label)
		else:
			var label = Label.new()
			label.add_theme_font_override("font", BYLIGHT)
			label.text = segment
			label.size = text_size + Vector2(0, 8)
			label.valign = Label.VALIGN_CENTER
			label.position.x = x_position
			add_child(label)
		x_position += text_size.x
	
	# Resize the main block
	custom_minimum_size = Vector2()
	size = Vector2(x_position + 20, BYLIGHT.get_height() + 15)
	if data.display == "holster":
		size.y += 30
	holster_size_y = size.y


func move_piece(position):
	var delta = position - global_position
	var piece_queue = [self]
	while !piece_queue.is_empty():
		var current_piece = piece_queue.pop_back()
		current_piece.global_position += delta
		if current_piece.bottom_connection:
			piece_queue.append(current_piece.bottom_connection)
		if current_piece.inner_connection:
			piece_queue.append(current_piece.inner_connection)

# Make the piece connect to other pieces
func snap_to_others():
	for piece in graph.get_children():
		if piece != self:
			var top = get_anchor_position("top_connection")
			var inner = piece.get_anchor_position("inner_connection")
			var bottom = piece.get_anchor_position("bottom_connection")
			# Bottom connection check
			var dist_squared = bottom.distance_squared_to(top)
			if dist_squared <= 900 && !piece.bottom_connection:
				move_piece(bottom - piece_anchor_points[json_data.display].top_connection)
				return [piece, "bottom_connection"]
			# Inner connection check
			dist_squared = inner.distance_squared_to(top)
			if dist_squared <= 900 && !piece.inner_connection:
				move_piece(inner - piece_anchor_points[json_data.display].top_connection)
				return [piece, "inner_connection"]

# Creation drag
func _input(event):
	if creation_drag:
		if event is InputEventMouseButton and event.is_action_released("ld_place"):
			creation_drag = false
			# Connect to the node on top
			var connection = snap_to_others()
			if connection:
				connection[0][connection[1]] = self
				set_top_connection(connection[0])
			accept_event()
		if event is InputEventMouseMotion:
			move_piece(get_global_mouse_position())
			snap_to_others()
			accept_event()

# A catch-all delete function for this node
# It's a bit wierd but it enscures all connections are properly dealt with
func delete_self(recursive):
	if top_connection:
		if top_connection.bottom_connection == self:
			top_connection.bottom_connection = null
		if top_connection.inner_connection == self:
			top_connection.inner_connection = null
		set_top_connection(null)
	if inner_connection:
		if recursive:
			inner_connection.delete_self(true)
		else:
			inner_connection.set_top_connection(null)
			inner_connection = null
	if bottom_connection:
		if recursive:
			bottom_connection.delete_self(true)
		else:
			bottom_connection.set_top_connection(null)
			bottom_connection = null
	queue_free()

# Duplicate the node
# It does not duplicate function arguments
func clone():
	var dupe = node_placer.drag_begin(json_data)
	# We use len(dupe.line_edits) not len(line_edits) since dynamic function arguments might error
	for index in len(dupe.line_edits):
		dupe.line_edits[index].text = line_edits[index].text


func dropdown_pressed(index, text):
	match text:
		"Duplicate":
			clone()
		"Delete":
			delete_self(false)
		"Delete all":
			delete_self(true)
		"Disconnect below":
			if bottom_connection:
				bottom_connection.move_piece(bottom_connection.global_position + Vector2(8, 8))
				bottom_connection.set_top_connection(null)
				bottom_connection = null
		"Disconnect inner":
			if inner_connection:
				inner_connection.move_piece(inner_connection.global_position + Vector2(8, 8))
				inner_connection.set_top_connection(null)
				inner_connection = null
		# TODO: Do the keyboard mode thingy
		"Insert below":
			node_placer.selected_node = self
			node_placer.selected_index = -1
		"Insert inner":
			node_placer.selected_node = self
			node_placer.selected_index = -2


func _gui_input(event):
	# Enable the dropdown menu for the nodes
	if event.is_action_pressed("ld_alt_click"):
		var dropdown = DropdownMenu.new()
		var options = [
			"Duplicate",
			"Delete",
			"Delete all",
			"---",
			"Insert below",
		]
		# Only holsters can have the inner option
		if json_data.display == "holster":
			options.append("Insert inner")
		options.append_array([
			("" if bottom_connection else "---#") + "Disconnect below",
			("" if inner_connection else "---#") + "Disconnect inner"
		])
		dropdown.options = options
		dropdown.global_position = get_global_mouse_position()# - global_position
		dropdown.theme = EDITOR_THEME
		dropdown.connect("button_pressed", Callable(self, "dropdown_pressed"))
		node_placer.add_child(dropdown)
		
		accept_event()
	
	# Handle being dragged.
	if event is InputEventMouseButton and event.is_action_pressed("ld_place"):
		being_dragged = global_position - get_global_mouse_position()
		# Disconnect the node from our top connection
		if top_connection:
			if top_connection.bottom_connection == self:
				top_connection.bottom_connection = null
			if top_connection.inner_connection == self:
				top_connection.inner_connection = null
		set_top_connection(null)
		accept_event()
	if event is InputEventMouseButton and event.is_action_released("ld_place"):
		being_dragged = false
		# Connect to the node on top
		var connection = snap_to_others()
		if connection:
			connection[0][connection[1]] = self
			set_top_connection(connection[0])
		accept_event()
	if being_dragged and event is InputEventMouseMotion:
		move_piece(get_global_mouse_position() + being_dragged)
		snap_to_others()
		accept_event()
