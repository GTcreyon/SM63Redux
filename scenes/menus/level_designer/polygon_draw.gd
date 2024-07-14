extends Control

signal move_vertex(index)
signal new_vertex(wanted_position, start_index, end_index)

@export var outline_color: Color = Color(0, 0.2, 0.9)

var polygon = []: set = set_polygon
var readonly_local_polygon = PackedVector2Array()
var show_verts = false: set = set_buttons
var draw_predict_line = true
var transparent_connector = true

const VERT_BUTTON_HALF_SIZE = Vector2(6, 6)
const VERT_BUTTON_PARAMETER_SQUARED = (VERT_BUTTON_HALF_SIZE.x * 2) ** 2

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
	if len(readonly_local_polygon) == 0:
		return
	
	var transparent_color = Color(outline_color)
	transparent_color.a = 0.4
	
	for index in readonly_local_polygon.size() - 1:
		draw_line(
			readonly_local_polygon[index],
			readonly_local_polygon[index + 1],
			outline_color,
			2
		)
	draw_line(
		readonly_local_polygon[0],
		main.get_snapped_mouse_position() - global_position if draw_predict_line else readonly_local_polygon[len(readonly_local_polygon) - 1],
		transparent_color if transparent_connector else outline_color,
		2
	)
	
	if show_verts:
		var mouse_position: Vector2 = main.get_snapped_mouse_position() - global_position
		var poly_size = readonly_local_polygon.size()
		# Find the closest point to the polygon
		var nearest_position
		var nearest_distance = INF
		var can_place = true
		for index in poly_size - 1:
			var seg_begin = readonly_local_polygon[index]
			var seg_end = readonly_local_polygon[(index + 1) % poly_size]
			var closest_point = Geometry2D.get_closest_point_to_segment(
				mouse_position,
				seg_begin,
				seg_end
			)
			var distance = mouse_position.distance_squared_to(closest_point)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_position = closest_point
				
				# Check if the button is too close to the normal buttons
				# If so, don't allow it
				var too_close_distance = min(
					seg_begin.distance_squared_to(nearest_position),
					seg_end.distance_squared_to(nearest_position)
				)
				can_place = too_close_distance > VERT_BUTTON_PARAMETER_SQUARED
				
				new_node_data.position = nearest_position
				new_node_data.start_index = index
				new_node_data.end_index = (index + 1) % poly_size
		if nearest_position and mouse_position and new_vertex_button and can_place:
			new_vertex_button.position = nearest_position - VERT_BUTTON_HALF_SIZE
	
	if draw_predict_line:
		draw_line(
			main.get_snapped_mouse_position() - global_position,
			readonly_local_polygon[len(readonly_local_polygon) - 1],
			transparent_color,
			2,
			true
		)


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
