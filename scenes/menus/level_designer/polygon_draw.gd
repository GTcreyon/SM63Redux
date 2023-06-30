extends Control

signal button_pressed
signal new_vert_button_pressed

@onready var main = $"/root/Main"

@onready var button_texture = preload("res://scenes/menus/level_designer/ldui/drag_circle.png")
@onready var button_texture_hover = preload("res://scenes/menus/level_designer/ldui/drag_circle_hover.png")
@onready var button_texture_pressed = preload("res://scenes/menus/level_designer/ldui/drag_circle_selected.png")

var polygon = []: set = set_polygon
var readonly_local_polygon = PackedVector2Array()
var should_have_buttons = false: set = set_buttons
var should_draw_predict_line = true
var should_connector_be_transparent = true
@export var outline_color: Color = Color(0, 0.2, 0.9)

func set_buttons(new):
	should_have_buttons = new
	reparent_buttons()

func on_button_press(index):
	emit_signal("button_pressed", index)

func on_new_vert_button_pressed():
	emit_signal("new_vert_button_pressed")

func reparent_buttons():
	for child in get_children():
		child.queue_free()
	if should_have_buttons:
		for index in readonly_local_polygon.size():
			var button = TextureButton.new()
			button.texture_normal = button_texture
			button.texture_hover = button_texture_hover
			button.texture_pressed = button_texture_pressed
			button.position = readonly_local_polygon[index] - Vector2(6, 6)
			button.connect("pressed", Callable(self, "on_button_press").bind(index))
			add_child(button)
		
		# This button is for adding vertices
		var button = TextureButton.new()
		button.name = "AddVertButton"
		button.texture_normal = button_texture
		button.texture_hover = button_texture_hover
		button.texture_pressed = button_texture_pressed
		button.position = readonly_local_polygon[0] - Vector2(6, 6)
		button.connect("pressed", Callable(self, "on_new_vert_button_pressed"))
		add_child(button)
		print(button.name)

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
	
	update()

# Yuck
func _process(_dt):
	if should_draw_predict_line or should_have_buttons:
		calculate_bounds()
		update()

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
	
	# FIXME: this should have it's own flag
	if should_have_buttons:
		var mouse_position: Vector2 = main.get_snapped_mouse_position() - global_position
		var poly_size = readonly_local_polygon.size()
		# Find the closest point to the polygon
		var nearest_position
		var nearest_distance = INF
		for index in poly_size - 1:
			var seg_begin = readonly_local_polygon[index]
			var seg_end = readonly_local_polygon[(index + 1) % poly_size]
			var closest_point = Geometry.get_closest_point_to_segment(
				mouse_position,
				seg_begin,
				seg_end
			)
			var distance = mouse_position.distance_squared_to(closest_point)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_position = closest_point
		var vert_button = get_node("AddVertButton")
		if nearest_position and mouse_position and vert_button:
			vert_button.position = nearest_position - Vector2(6, 6)
#			draw_line(mouse_position, nearest_position, Color(1, 0, 0))
#			draw_circle(mouse_position, 1, Color(0.7, 0, 0))
	
	if should_draw_predict_line:
		draw_line(
			main.get_snapped_mouse_position() - global_position,
			readonly_local_polygon[len(readonly_local_polygon) - 1],
			transparent_color,
			2,
			true
		)
