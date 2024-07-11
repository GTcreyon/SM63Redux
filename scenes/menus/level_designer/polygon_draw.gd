extends Control

signal move_vertex(index)
signal new_vertex(wanted_position, start_index, end_index)

@export var outline_color: Color = Color(0, 0.2, 0.9)

var polygon = []: set = set_polygon
var readonly_local_polygon = PackedVector2Array()
var should_have_buttons = false: set = set_buttons
var should_draw_predict_line = true
var should_connector_be_transparent = true

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


# Yuck
func _process(_dt):
	if should_draw_predict_line or should_have_buttons:
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
		main.get_snapped_mouse_position() - global_position if should_draw_predict_line else readonly_local_polygon[len(readonly_local_polygon) - 1],
		transparent_color if should_connector_be_transparent else outline_color,
		2
	)
	
	if should_have_buttons:
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
	
	if should_draw_predict_line:
		draw_line(
			main.get_snapped_mouse_position() - global_position,
			readonly_local_polygon[len(readonly_local_polygon) - 1],
			transparent_color,
			2,
			true
		)


func set_buttons(new):
	should_have_buttons = new
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
	if !should_have_buttons:
		for child in get_children():
			child.queue_free()
		return
	
	var actual_child_count = get_child_count() - 1
	if actual_child_count > readonly_local_polygon.size():
		for index in range(readonly_local_polygon.size(), actual_child_count):
			var button = get_node_or_null("Vertex" + str(index))
			if !button:
				printerr("Too many buttons for this polygon, but unable to find index ", index)
				continue
			button.queue_free()
	
	for index in readonly_local_polygon.size():
		var button = get_node_or_null("Vertex" + str(index))
		if !button:
			button = TextureButton.new()
			button.name = "Vertex" + str(index)
			button.texture_normal = button_texture
			button.texture_hover = button_texture_hover
			button.texture_pressed = button_texture_pressed
			button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
			button.connect("pressed", Callable(self, "on_button_press").bind(index))
			add_child(button)
		button.position = readonly_local_polygon[index] - VERT_BUTTON_HALF_SIZE
	
	# This button is for adding vertices
	if !new_vertex_button:
		var button = TextureButton.new()
		button.name = "NewVertex"
		button.texture_normal = button_texture
		button.texture_hover = button_texture_hover
		button.texture_pressed = button_texture_pressed
		button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
		button.connect("pressed", Callable(self, "on_new_vert_button_pressed"))
		new_vertex_button = button
		add_child(button)
	new_vertex_button.position = readonly_local_polygon[0] - VERT_BUTTON_HALF_SIZE

func calculate_bounds():
	var min_vec = Vector2.INF
	var max_vec = -Vector2.INF
	for item in polygon:
		min_vec.x = min(item.x, min_vec.x)
		min_vec.y = min(item.y, min_vec.y)
		max_vec.x = max(item.x, max_vec.x)
		max_vec.y = max(item.y, max_vec.y)
	
	if should_draw_predict_line:
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
