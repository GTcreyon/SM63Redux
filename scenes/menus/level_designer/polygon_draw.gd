extends Control

signal move_vertex(index)
signal new_vertex(wanted_position, start_index, end_index)

const VERT_BUTTON_HALF_SIZE = Vector2(6, 6)
## If the mouse is within this distance of a placed vertex,
## the new-vertex widget will be disabled.
const NO_ADD_VERT_DIST = VERT_BUTTON_HALF_SIZE.x * 2

const LINE_WIDTH = 2
const LINE_ANTIALIAS = false

@export var outline_color: Color = Color(0, 0.2, 0.9)

var polygon = []: set = set_polygon
var readonly_local_polygon = PackedVector2Array()
var show_verts = false: set = set_buttons
## Used to show transparent lines during initial polygon creation.
var draw_predict_line = true


# Private
var new_node_data = {
	position = Vector2.ZERO,
	start_index = 0,
	end_index = 0,
}
var new_vertex_button

@onready var main = $"/root/Main"

@onready var button_texture = preload("res://scenes/menus/level_designer/poly_edit/vertex.png")
@onready var button_texture_hover = preload("res://scenes/menus/level_designer/poly_edit/vertex_hover.png")
@onready var button_texture_pressed = preload("res://scenes/menus/level_designer/poly_edit/vertex_selected.png")

@onready var new_vert_template: TextureButton = $"NewVert"
@onready var placed_vert_template: TextureButton = $"PlacedVert"


func _ready():
	# Pull these out of the scene tree so they can be used as templates.
	remove_child(new_vert_template)
	remove_child(placed_vert_template)


# Yuck
func _process(_dt):
	if draw_predict_line or show_verts:
		calculate_bounds()
		queue_redraw()


func _draw():
	# Abort if the polygon is empty, since there'd be nothing to draw.
	if len(readonly_local_polygon) == 0:
		return
	
	var transparent_color = Color(outline_color)
	transparent_color.a = 0.4
	
	# Render all placed edges.
	for index in readonly_local_polygon.size() - 1:
		draw_line(
			readonly_local_polygon[index],
			readonly_local_polygon[index + 1],
			outline_color,
			LINE_WIDTH,
			LINE_ANTIALIAS
		)
	
	if draw_predict_line:
		# During initial polygon placement, speculatively bridge the gap between
		# the start and end vertices with transparent lines to and from
		# the mouse cursor. This to preview where the next vert *could* be.
		draw_line(
			readonly_local_polygon[0],
			main.get_snapped_mouse_position() - global_position,
			transparent_color,
			LINE_WIDTH,
			LINE_ANTIALIAS
		)
		draw_line(
			main.get_snapped_mouse_position() - global_position,
			readonly_local_polygon[len(readonly_local_polygon) - 1],
			transparent_color,
			LINE_WIDTH,
			LINE_ANTIALIAS
		)
	else:
		# Draw a line to bridge the gap between the start and end vertices.
		draw_line(
			readonly_local_polygon[0],
			readonly_local_polygon[len(readonly_local_polygon) - 1],
			outline_color,
			LINE_WIDTH,
			LINE_ANTIALIAS
		)
	
	# Draw the add-vert widget (if verts are shown right now).
	if show_verts:
		var vert_count = readonly_local_polygon.size()
		var mouse_position: Vector2 = main.get_snapped_mouse_position() - global_position
		
		# Find the point on the polygon which is nearest to the mouse.
		var nearest_position
		var nearest_distance = INF
		var can_place = true
		for index in vert_count - 1:
			# Find the closest point on this segment (the segment starting on
			# this index).
			var seg_begin = readonly_local_polygon[index]
			var seg_end = readonly_local_polygon[(index + 1) % vert_count]
			var closest_point = Geometry2D.get_closest_point_to_segment(
				mouse_position,
				seg_begin,
				seg_end
			)
			
			# Compare with this frame's shortest-distance record.
			var distance = mouse_position.distance_squared_to(closest_point)
			if distance < nearest_distance:
				# It's a new shortest-distance record!
				nearest_distance = distance
				# Save the position which did it.
				nearest_position = closest_point
				
				# If the new vert is too close to the placed verts, disable its
				# updating (TODO: and hide it).
				var dist_to_placed = min(
					seg_begin.distance_squared_to(nearest_position),
					seg_end.distance_squared_to(nearest_position)
				)
				can_place = dist_to_placed > NO_ADD_VERT_DIST * NO_ADD_VERT_DIST
				
				# Save data about this segment for the adding process to use.
				new_node_data.position = nearest_position
				new_node_data.start_index = index
				new_node_data.end_index = (index + 1) % vert_count
		
		# Place new-vert widget on the calculated nearest point, if it exists,
		# there is a nearest point, and it's not too close to a placed vertex.
		if nearest_distance < INF and new_vertex_button != null and can_place:
			new_vertex_button.position = nearest_position - VERT_BUTTON_HALF_SIZE


func set_buttons(new):
	show_verts = new
	reparent_buttons()


func on_button_press(index):
	emit_signal("move_vertex", index)


func on_new_vert_button_pressed():
	emit_signal(
		"new_vertex",
		new_node_data.position,
		new_node_data.start_index,
		new_node_data.end_index
	)


func reparent_buttons():
	# If this function is called when verts are hidden, delete all vertex UI
	# elements, then abort.
	if !show_verts:
		for child in get_children():
			child.queue_free()
		return
	
	# Clean up placed-verts which are extra for this size of polygon.
	# First, check if there actually are extras....
	var actual_child_count = get_child_count() - 1
	if actual_child_count > readonly_local_polygon.size():
		# Iterate all verts past the needed number.
		for index in range(readonly_local_polygon.size(), actual_child_count):
			# Find the widget for this index.
			var button = get_node_or_null("Vertex" + str(index))
			# VALIDATE: this widget ought to exist if we're already checking for it,
			# i.e. there should be no gaps in the sequence of editable indices.
			if !button:
				printerr("Unable to find vertex ", index, " despite having extra vertex widgets.")
				continue
			# Delete it.
			button.queue_free()
	
	# Update placed vertices.
	for index in readonly_local_polygon.size():
		# Find vert with this index.
		var button = get_node_or_null("Vertex" + str(index))
		# Create and add it if it doesn't exist.
		if !button:
			button = placed_vert_template.duplicate()
			button.name = "Vertex" + str(index)
			# Connect it to the button-press signal, binding the correct index.
			# The index binding means we can't set this in the editor.
			button.connect("pressed", Callable(self, "on_button_press").bind(index))
			add_child(button)
		# Put it at the correct position for this index.
		button.position = readonly_local_polygon[index] - VERT_BUTTON_HALF_SIZE
	
	# Create new-vert button if it doesn't exist yet.
	# (Using the template node directly, and just removing it from the
	#  tree at the appropriate time, causes vertex adding to behave oddly.)
	# (Like unusably so.)
	if !new_vertex_button:
		new_vertex_button = new_vert_template.duplicate()
		add_child(new_vertex_button)
	# Place the new-vert button in a sensible temp spot. (Mouse input should
	# overwrite this soon, but just in case.)
	new_vertex_button.position = readonly_local_polygon[0] - VERT_BUTTON_HALF_SIZE

func calculate_bounds():
	var min_vec = Vector2.INF
	var max_vec = -Vector2.INF
	for item in polygon:
		min_vec.x = min(item.x, min_vec.x)
		min_vec.y = min(item.y, min_vec.y)
		max_vec.x = max(item.x, max_vec.x)
		max_vec.y = max(item.y, max_vec.y)
	
	if draw_predict_line:
		var item = main.get_snapped_mouse_position()
		min_vec.x = min(item.x, min_vec.x)
		min_vec.y = min(item.y, min_vec.y)
		max_vec.x = max(item.x, max_vec.x)
		max_vec.y = max(item.y, max_vec.y)
		
	global_position = min_vec
	size = max_vec - min_vec
	readonly_local_polygon = PackedVector2Array()
	for item in polygon:
		readonly_local_polygon.append(item - global_position)


func set_polygon(new):
	polygon = new
	
	# Convert the global coords polygon to a local coords one for drawing
	readonly_local_polygon = PackedVector2Array()
	if len(polygon) != 0:
		calculate_bounds()
		
		reparent_buttons()
	
	queue_redraw()
