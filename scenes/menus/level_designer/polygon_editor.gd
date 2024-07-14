extends Control

@onready var main = $"/root/Main"
@onready var drawable_polygon = $Polygon

var dragging_index = null


func _unhandled_input(event):
	if main.editor_state == main.EDITOR_STATE.POLYGON_CREATE:
		if event.is_action_released("ld_cancel_placement") or event.is_action_released("ld_poly_cancel"):
			quit_creating(false)
		
		if event.is_action_released("ld_poly_finish"):
			quit_creating(true)
		
		if event.is_action_released("ld_place") and main.editor_state == main.EDITOR_STATE.POLYGON_CREATE:
			drawable_polygon.polygon = drawable_polygon.polygon + [main.get_snapped_mouse_position()]
			if len(drawable_polygon.polygon) > 2 and !Input.is_action_pressed("ld_keep_place"):
				quit_creating(true)
	elif main.editor_state == main.EDITOR_STATE.POLYGON_DRAG_VERTEX:
		if event.is_action_released("ld_place"):
			dragging_index = null
			drawable_polygon.show_verts = true
			main.editor_state = main.EDITOR_STATE.POLYGON_EDIT
	elif main.editor_state == main.EDITOR_STATE.POLYGON_EDIT:
		if event.is_action_released("ld_poly_cancel"):
			stop_editing_polygon(false)
		if event.is_action_released("ld_poly_finish"):
			stop_editing_polygon(true)

func quit_creating(save):
	main.editor_state = main.EDITOR_STATE.IDLE
	var polygon_data = PackedVector2Array(drawable_polygon.readonly_local_polygon)
	var polygon_position = drawable_polygon.global_position
	drawable_polygon.polygon = []
	drawable_polygon.draw_predict_line = false
	drawable_polygon.show_verts = false
	
	if len(polygon_data) > 2 and save:
		if Geometry2D.is_polygon_clockwise(polygon_data):
			polygon_data.reverse()
		
		polygon_data.append(polygon_data[0])
		var terrain = main.place_terrain(polygon_data)
		terrain.position = polygon_position


func start_polygon_creation():
	if main.editor_state != main.EDITOR_STATE.IDLE:
		return
	main.editor_state = main.EDITOR_STATE.POLYGON_CREATE
	
	drawable_polygon.polygon = []
	drawable_polygon.draw_predict_line = true
	drawable_polygon.show_verts = false


func _on_new_vertex(wanted_position, start_index, end_index):
	print("New ", wanted_position, ", ", start_index, ", ", end_index)
	main.editor_state = main.EDITOR_STATE.POLYGON_DRAG_VERTEX
	
	drawable_polygon.show_verts = false
	# We have to copy the array, otherwise the set-invocation won't work
	var copied = drawable_polygon.polygon.duplicate(false)
	copied.insert(end_index, drawable_polygon.position + wanted_position)
	drawable_polygon.polygon = copied
	dragging_index = end_index


func _on_vertex_move(index):
	print("Moving ", index)
	main.editor_state = main.EDITOR_STATE.POLYGON_DRAG_VERTEX
	drawable_polygon.show_verts = false
	dragging_index = index


func edit_polygon(obj_to_edit):
	if main.editor_state != main.EDITOR_STATE.IDLE:
		return
	main.editor_state = main.EDITOR_STATE.POLYGON_EDIT
	main.polygon_edit_node = obj_to_edit
	
	obj_to_edit.visible = false
	
	var data = []
	for vec in obj_to_edit.polygon:
		data.append(vec + obj_to_edit.position)
	
	drawable_polygon.polygon = data
	drawable_polygon.draw_predict_line = false
	drawable_polygon.show_verts = true


func stop_editing_polygon(save):
	if main.editor_state != main.EDITOR_STATE.POLYGON_EDIT:
		return
	main.editor_state = main.EDITOR_STATE.IDLE
	
	var polygon_data = PackedVector2Array(drawable_polygon.readonly_local_polygon)
	var polygon_position = drawable_polygon.global_position
	drawable_polygon.polygon = []
	drawable_polygon.draw_predict_line = false
	drawable_polygon.show_verts = false
	
	if save:
		main.polygon_edit_node.position = polygon_position
		main.polygon_edit_node.polygon = polygon_data
	main.polygon_edit_node.visible = true

func _process(delta):
	if main.editor_state == main.EDITOR_STATE.POLYGON_DRAG_VERTEX and dragging_index != null:
		var mouse_position = main.get_snapped_mouse_position()
		drawable_polygon.polygon[dragging_index] = mouse_position
		drawable_polygon.polygon = drawable_polygon.polygon


func _demo_press():
	start_polygon_creation()
