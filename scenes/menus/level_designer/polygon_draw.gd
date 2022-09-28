extends Control

signal button_pressed

onready var main = $"/root/Main"

onready var button_texture = preload("res://scenes/menus/level_designer/ldui/drag_circle.png")
onready var button_texture_hover = preload("res://scenes/menus/level_designer/ldui/drag_circle_hover.png")
onready var button_texture_pressed = preload("res://scenes/menus/level_designer/ldui/drag_circle_selected.png")

var polygon = [] setget set_polygon
var readonly_local_polygon = PoolVector2Array()
var should_have_buttons = false setget set_buttons
var should_draw_predict_line = true
var should_connector_be_transparent = true
export(Color) var outline_color = Color(0, 0.2, 0.9)

func set_buttons(new):
	should_have_buttons = new
	reparent_buttons()

func on_button_press(index):
	emit_signal("button_pressed", index)

func reparent_buttons():
	for child in get_children():
		child.queue_free()
	if should_have_buttons:
		for index in readonly_local_polygon.size():
			var button = TextureButton.new()
			button.texture_normal = button_texture
			button.texture_hover = button_texture_hover
			button.texture_pressed = button_texture_pressed
			button.rect_position = readonly_local_polygon[index]
			button.connect("pressed", "on_button_press", index)
			add_child(button)

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
		
	rect_global_position = min_vec
	rect_size = max_vec - min_vec
	readonly_local_polygon = PoolVector2Array()
	for item in polygon:
		readonly_local_polygon.append(item - rect_global_position)

func set_polygon(new):
	polygon = new
	
	# Convert the global coords polygon to a local coords one for drawing
	readonly_local_polygon = PoolVector2Array()
	if len(polygon) != 0:
		calculate_bounds()
		
		reparent_buttons()
	
	update()

# Yuck
func _process(_dt):
	if should_draw_predict_line:
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
		main.get_snapped_mouse_position() - rect_global_position if should_draw_predict_line else readonly_local_polygon[len(readonly_local_polygon) - 1],
		transparent_color if should_connector_be_transparent else outline_color,
		2
	)
	
	if should_draw_predict_line:
		draw_line(
			main.get_snapped_mouse_position() - rect_global_position,
			readonly_local_polygon[len(readonly_local_polygon) - 1],
			transparent_color,
			2,
			true
		)
	
