extends NinePatchRect

onready var graph = get_parent()

const BYLIGHT = preload("res://fonts/bylight/bylight.tres")

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
		width += BYLIGHT.get_char_size(c as int).x
	return Vector2(width, BYLIGHT.get_height())

func setup(data):
	json_data = data
	# Create the labels within the block
	var segments = data.segments.split(" ", false)
	var x_position = 0
	for segment in segments:
		var text_size = get_text_width(segment)
		match segment:
			"$expression":
				print("Woo!")
			"$label":
				print("Variable labels, cool!")
			"$variable":
				print("Wow this is a variable.")
			_:
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
		rect_size.y += 60
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
