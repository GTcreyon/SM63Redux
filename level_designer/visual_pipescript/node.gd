extends NinePatchRect

onready var graph = get_parent()

const BYLIGHT = preload("res://fonts/bylight/bylight.tres")
const STYLEBOX = preload("res://level_designer/visual_pipescript/line_edit_style.stylebox")

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
var top_connection setget set_top_connection
var inner_connection
var bottom_connection

var being_dragged = false
var holster_size_y = 0
var json_data

var line_edits = []

func get_input_text(idx):
	# TODO: Make to validate user data, you can do this by
	# reading the tags inside of segments in pieces.json
	# and then checking if it's valid or not
	if line_edits[idx]:
		if line_edits[idx].text.empty():
			printerr("%s is not filled in!" % name)
		return line_edits[idx].text
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
	var original_size = rect_size.y
	rect_size.y = holster_size_y
	var piece = self.inner_connection
	while piece:
		rect_size.y += piece.rect_size.y
		piece = piece.bottom_connection
	if bottom_connection:
		bottom_connection.move_piece(
			bottom_connection.rect_global_position + Vector2(0, rect_size.y - original_size)
		)

func get_anchor_position(type: String) -> Vector2:
	match type:
		"bottom_connection":
			return rect_global_position + Vector2(0, rect_size.y) + piece_anchor_points[json_data.display][type]
		_:
			return rect_global_position + piece_anchor_points[json_data.display][type]

func get_text_width(text: String) -> Vector2:
	var width = 0
	for c in text:
		if c != " ":
			width += BYLIGHT.get_char_size(c as int).x
	return Vector2(width, BYLIGHT.get_height())

func add_input_field_on_press(button, field_text):
	var text_size = get_text_width(field_text)
	var label = LineEdit.new()
	label.add_font_override("font", BYLIGHT)
	label.add_stylebox_override("normal", STYLEBOX)
	label.placeholder_text = field_text
	label.rect_size = text_size - Vector2(8, 0)
	label.rect_position = Vector2(button.rect_position.x, 4)
	add_child(label)
	line_edits.append(label)
	button.rect_position.x += text_size.x
	rect_size.x += text_size.x

func setup(data):
	line_edits = []
	json_data = data
	# Create the labels within the block
	var segments = data.segments.split(" ", false)
	var x_position = 0
	for segment in segments:
		var text_size = get_text_width(segment)
		if segment.begins_with("$+"):
			var button = Button.new()
			button.add_font_override("font", BYLIGHT)
			button.add_stylebox_override("normal", STYLEBOX)
			button.text = "+"
			text_size = get_text_width(button.text)
			button.align = Button.ALIGN_CENTER
			button.rect_position = Vector2(x_position, 4)
			button.connect("pressed", self, "add_input_field_on_press", [button, segment.substr(2)])
			add_child(button)
		elif segment.begins_with("$"):
			var label = LineEdit.new()
			label.add_font_override("font", BYLIGHT)
			label.add_stylebox_override("normal", STYLEBOX)
			label.placeholder_text = segment.substr(1)
			label.rect_size = text_size + Vector2(-8, 0)
			label.rect_position = Vector2(x_position, 4)
			add_child(label)
			line_edits.append(label)
		else:
			var label = Label.new()
			label.add_font_override("font", BYLIGHT)
			label.text = segment
			label.rect_size = text_size + Vector2(0, 8)
			label.valign = Label.VALIGN_CENTER
			label.rect_position.x = x_position
			add_child(label)
		x_position += text_size.x
	
	# Resize the main block
	rect_min_size = Vector2()
	rect_size = Vector2(x_position + 20, BYLIGHT.get_height() + 15)
	if data.display == "holster":
		rect_size.y += 30
	holster_size_y = rect_size.y

func move_piece(position):
	var delta = position - rect_global_position
	var piece_queue = [self]
	while !piece_queue.empty():
		var current_piece = piece_queue.pop_back()
		current_piece.rect_global_position += delta
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

# Handle being dragged.
func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		being_dragged = rect_global_position - get_global_mouse_position()
		# Disconnect the node from our top connection
		if top_connection:
			if top_connection.bottom_connection == self:
				top_connection.bottom_connection = null
			if top_connection.inner_connection == self:
				top_connection.inner_connection = null
		set_top_connection(null)
	if event is InputEventMouseButton and not event.pressed:
		being_dragged = false
		# Connect to the node on top
		var connection = snap_to_others()
		if connection:
			connection[0][connection[1]] = self
			set_top_connection(connection[0])
	if being_dragged and event is InputEventMouseMotion:
		move_piece(get_global_mouse_position() + being_dragged)
		snap_to_others()
