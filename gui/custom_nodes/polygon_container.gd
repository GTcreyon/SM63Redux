extends Container

class_name PolygonContainer

@export var polygon: PackedVector2Array = PackedVector2Array(): set = set_polygon
@export var color: Color = Color(0.5, 0.25, 0)
@export var head_color: Color = Color.WHITE
@export var foot_color: Color = Color.WHITE
@export var width: int = 2


func set_polygon(new):
	polygon = new
	queue_sort()
	queue_redraw()


func append(pos):
	polygon.append(pos)
	var button = TextureButton.new()
	button.set_position(pos)
	button.set_size(Vector2(12, 12))
	button.action_mode = BaseButton.ACTION_MODE_BUTTON_PRESS
	button.texture_normal = preload("res://scenes/menus/level_designer/poly_edit/vertex.png")
	button.texture_hover = preload("res://scenes/menus/level_designer/poly_edit/vertex_hover.png")
	button.texture_pressed = preload("res://scenes/menus/level_designer/poly_edit/vertex_selected.png")
	add_child(button)
	queue_sort()
	return button


func set_vert(idx, pos):
	polygon[idx] = pos
	queue_sort()
	queue_redraw()


func reset():
	polygon = []
	for child in get_children():
		remove_child(child)
	queue_sort()
	queue_redraw()


func _notification(what):
	if what != NOTIFICATION_SORT_CHILDREN:
		return
	
	var p_size = polygon.size()
	for idx in p_size:
		var child = get_child(idx)
		if child:
			if idx == p_size - 1:
				child.modulate = head_color
			elif idx == 0:
				child.modulate = foot_color
			else:
				child.modulate = Color.WHITE
			child.set_position(polygon[idx] - child.size / 2)


func _draw():
	var p_size = polygon.size()
	for idx in p_size:
		draw_line(polygon[idx], polygon[(idx + 1) % p_size], color, width)
