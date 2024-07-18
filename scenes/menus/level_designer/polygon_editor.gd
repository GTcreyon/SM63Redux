class_name PolygonEditor
extends Control

## Emitted when tthe polygon is deleted from within the polygon editor.
## (Currently, this can only happen by removing verts until there's < 3 left.)
##
## The parameter is a reference to the deleted polygon. Keep in mind, this
## polygon has already had queue_free() called on it by the time the signal is
## emitted!
signal polygon_deleted(polygon: Polygon2D)

@onready var main = $"/root/Main"
@onready var drawable_polygon = $Polygon

var dragging_index = null


func _process(delta):
	if main.editor_state == main.EDITOR_STATE.POLYGON_DRAG_VERTEX and dragging_index != null:
		var mouse_position = main.get_snapped_mouse_position()
		drawable_polygon.polygon[dragging_index] = mouse_position
		drawable_polygon.polygon = drawable_polygon.polygon


func _unhandled_input(event):
	if main.editor_state == main.EDITOR_STATE.POLYGON_CREATE:
		if event.is_action_released("ld_cancel_placement") or event.is_action_released("ld_poly_cancel"):
			_end_create(false)
		
		if event.is_action_released("ld_poly_finish"):
			_end_create(true)
		
		if event.is_action_released("ld_place") and main.editor_state == main.EDITOR_STATE.POLYGON_CREATE:
			drawable_polygon.polygon.append(main.get_snapped_mouse_position())
			drawable_polygon.refresh_polygon()
			if len(drawable_polygon.polygon) > 2 and !Input.is_action_pressed("ld_keep_place"):
				_end_create(true)
	elif main.editor_state == main.EDITOR_STATE.POLYGON_DRAG_VERTEX:
		if event.is_action_released("ld_place"):
			main.editor_state = main.EDITOR_STATE.POLYGON_EDIT
			dragging_index = null
			drawable_polygon.end_drag()
	elif main.editor_state == main.EDITOR_STATE.POLYGON_EDIT:
		if event.is_action_released("ld_poly_cancel"):
			_end_edit(false)
		if event.is_action_released("ld_poly_finish"):
			_end_edit(true)


func _begin_create():
	if main.editor_state != main.EDITOR_STATE.IDLE:
		return
	main.editor_state = main.EDITOR_STATE.POLYGON_CREATE
	
	# Godot doesn't accept [] as a typed array, so for now, a workaround.
	var empty_array: Array[Vector2] = []
	drawable_polygon.begin_edit(empty_array)


func _end_create(save: bool):
	main.editor_state = main.EDITOR_STATE.IDLE
	var polygon_data = PackedVector2Array(drawable_polygon.readonly_local_polygon)
	var polygon_position = drawable_polygon.global_position
	drawable_polygon.end_edit()
	
	if len(polygon_data) > 2 and save:
		if Geometry2D.is_polygon_clockwise(polygon_data):
			polygon_data.reverse()
		
		polygon_data.append(polygon_data[0])
		var terrain = main.place_terrain(polygon_data)
		terrain.position = polygon_position


## Begins editing the given Polygon2D.
func begin_edit(obj_to_edit: Polygon2D):
	if main.editor_state != main.EDITOR_STATE.IDLE:
		return
	main.editor_state = main.EDITOR_STATE.POLYGON_EDIT
	
	main.polygon_edit_node = obj_to_edit
	
	assert(obj_to_edit.polygon.size() > 0,
		"Shouldn't be possible to enter polygon edit mode on an empty polygon.")
	
	obj_to_edit.visible = false
	
	# Create a world-space copy of the polygon's points array.
	var data: Array[Vector2] = [] # type hint required so inner begin_edit works
	for point in obj_to_edit.polygon:
		data.append(point + obj_to_edit.position)
	
	drawable_polygon.begin_edit(data)


func _end_edit(save: bool):
	if main.editor_state != main.EDITOR_STATE.POLYGON_EDIT:
		return
	main.editor_state = main.EDITOR_STATE.IDLE
	
	var polygon_data = PackedVector2Array(drawable_polygon.readonly_local_polygon)
	var polygon_position = drawable_polygon.global_position
	drawable_polygon.end_edit()
	
	if save:
		main.polygon_edit_node.position = polygon_position
		main.polygon_edit_node.polygon = polygon_data
	main.polygon_edit_node.visible = true


func add_vertex(at_position: Vector2, at_index: int):
	print("New at ", at_position, ", index ", at_index)
	
	# Update the drawable's polygon.
	drawable_polygon.polygon.insert(at_index, drawable_polygon.position + at_position)
	# Awkwardly enough, the drawable won't run its update-on-change code when
	# polygon is modified instead of set fresh. Run it manually instead.
	drawable_polygon.refresh_polygon()
	
	_begin_move_vertex(at_index)


func remove_vertex(index):
	print("Remove ", index)
	
	# Check if there'll be enough verts left without this one to still form
	# a polygon.
	# (Why -1? Because there's an extra one being added to close the gap between
	# first and last.)
	if drawable_polygon.polygon.size()-1 <= 3:
		# Polygon has too few verts to remove one and still be a polygon.
		# Delete the entire target node rather than let the geometry
		# become degenerate.
		print("Delete polygon")
		delete_polygon()
		# TODO: Eventually would be nice to use this same system for placing
		# open lines as well as closed polygons.
		# In that case, fewer than 3 verts should be allowable.
	else:
		drawable_polygon.polygon.remove_at(index)
		drawable_polygon.refresh_polygon()


func _begin_move_vertex(index):
	print("Moving ", index)
	main.editor_state = main.EDITOR_STATE.POLYGON_DRAG_VERTEX
	dragging_index = index
	
	drawable_polygon.begin_drag()


func delete_polygon():
	_end_edit(false)
	main.polygon_edit_node.queue_free()
	
	polygon_deleted.emit(main.polygon_edit_node)


func _demo_press():
	_begin_create()
