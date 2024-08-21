class_name PolygonEditor
extends Control

## Emitted when tthe polygon is deleted from within the polygon editor.
## (Currently, this can only happen by removing verts until there's < 3 left.)
##
## The parameter is a reference to the deleted polygon. Keep in mind, this
## polygon has already had queue_free() called on it by the time the signal is
## emitted!
signal polygon_deleted(polygon: Polygon2D)

## Should the changes be shown in realtime on the edited polygon?
@export var show_target := true

var dragging_index = null

@onready var main: LDMain = $"/root/Main"
@onready var drawable_polygon = $Polygon

func _process(delta):
	# If dragging a vertex, place the visual vertex on the mouse.
	if main.editor_state == main.EDITOR_STATE.POLYGON_DRAG_VERTEX and dragging_index != null:
		var mouse_position = main.get_snapped_mouse_position()
		drawable_polygon.polygon[dragging_index] = mouse_position
		drawable_polygon.is_valid = PolygonValidator.new().validate_polygon(
			drawable_polygon.polygon, drawable_polygon.polygon[dragging_index])
		drawable_polygon.refresh_polygon()
		
		# Update the target polygon, if updating the target is enabled.
		if show_target:
			# Position of mouse relative to the display polygon.
			var local_mouse = mouse_position - main.polygon_edit_node.position

			if dragging_index >= main.polygon_edit_node.polygon.size():
				# Dragged vert is past the end of the current polygon.
				
				# VALIDATE: currently dragging_index cannot validly be past
				# the end vert by more than 1 index.
				# Assert validity with a useful message.
				# For the record, current buggy behavior would add new verts
				# every frame until the drag index is reached.
				assert(dragging_index == main.polygon_edit_node.polygon.size(),
					"""Index of dragged vertex is further beyond the end than
					polygon preview rendering can currently handle.
					At the moment it can support up to 1 beyond the end.
					""")
				
				# For display purposes, add the dragged vert to the polygon.
				main.polygon_edit_node.polygon.append(local_mouse)
				# TODO: Ensure that if vertex-adding becomes cancelable,
				# this temporary display vert is properly removed.
			else:
				# Dragged vert is in the polygon already. Set its position
				# normally.
				main.polygon_edit_node.polygon[dragging_index] = local_mouse


func _unhandled_input(event):
	match main.editor_state:
		main.EDITOR_STATE.POLYGON_CREATE:
			# Creating a polygon.
			# Cancel creation if either cancel button is pressed.
			if event.is_action_released("ld_cancel_placement") or event.is_action_released("ld_poly_cancel"):
				_end_create(false)
			
			# Finish creation on presseing finish.
			if event.is_action_released("ld_poly_finish"):
				_end_create(true)
			
			# Place verts on click.
			if event.is_action_released("ld_place") and main.editor_state == main.EDITOR_STATE.POLYGON_CREATE:
				# Add a vert at the end of the chain, wherever we clicked.
				drawable_polygon.polygon.append(main.get_snapped_mouse_position())
				drawable_polygon.refresh_polygon()
				
				# Don't need to run it through the validator here due to all triangles being simple polygons
				if len(drawable_polygon.polygon) >= 2: drawable_polygon.is_valid = true
				
				# Finish the polygon on placing the third point (without the
				# keep-placing button held).
				if len(drawable_polygon.polygon) > 2 and !Input.is_action_pressed("ld_keep_place"):
					_end_create(true)
		main.EDITOR_STATE.POLYGON_DRAG_VERTEX:
			# Dragging a vertex.
			
			# On click, finish the drag wherever the mouse is.
			if event.is_action_released("ld_place"):
				drawable_polygon.end_drag()
				
				main.editor_state = main.EDITOR_STATE.POLYGON_EDIT
				dragging_index = null
		main.EDITOR_STATE.POLYGON_EDIT:
			# Editing a placed polygon.
			
			if event.is_action_released("ld_poly_cancel"):
				_end_edit(false)
			if event.is_action_released("ld_poly_finish"):
				_end_edit(true)


func _begin_create():
	# Can't begin creating a polygon if we're doing something else.
	if main.editor_state != main.EDITOR_STATE.IDLE:
		return
	
	main.editor_state = main.EDITOR_STATE.POLYGON_CREATE
	
	# Godot doesn't accept [] as a typed array, so for now, a workaround.
	var empty_array: Array[Vector2] = []
	drawable_polygon.begin_edit(empty_array)


func _end_create(save: bool):
	# Revert to main state.
	main.editor_state = main.EDITOR_STATE.IDLE
	
	# Copy needed data out of the drawable.
	var polygon_data = PackedVector2Array(drawable_polygon.readonly_local_polygon)
	var polygon_position = drawable_polygon.global_position
	# Drawable is done now.
	drawable_polygon.end_edit()
	
	# Save polygon (if it has enough points to be a polygon) if needed.
	if len(polygon_data) > 2 and save:
		# Ensure the polygon winds counter-clockwise.
		if Geometry2D.is_polygon_clockwise(polygon_data):
			polygon_data.reverse()
		
		# Add an extra point at the end to close the polygon.
		# Disabled because it wasn't really fixing anything, and was creating
		# stacked verts at the start/end (which could be edited and dragged
		# apart, by accident...and regularly were).
		# If you re-enable this line, make sure to update remove_vertex to check
		# for one extra vertex in a min-sized polygon.
		#polygon_data.append(polygon_data[0])
		# Save the polygon data to a new node.
		var terrain = main.place_terrain(polygon_data)
		terrain.position = polygon_position


## Begins editing the given Polygon2D.
func begin_edit(obj_to_edit: Polygon2D):
	# Can't begin editing a polygon if we're doing something else.
	if main.editor_state != main.EDITOR_STATE.IDLE:
		return
	
	main.editor_state = main.EDITOR_STATE.POLYGON_EDIT
	
	# Save a global reference to the target node.
	main.polygon_edit_node = obj_to_edit
	main.polygon_edit_node.tree_exiting.connect(func(): 
		drawable_polygon.end_edit()
		drawable_polygon.is_valid = false
		)
	
	assert(obj_to_edit.polygon.size() > 0,
		"Shouldn't be possible to enter polygon edit mode on an empty polygon.")
	
	# Hide the target node for editing.
	if show_target:
		obj_to_edit.set_glowing(false)
	else:
		obj_to_edit.visible = false
	
	# Ensure the polyeditor properly cleans up and commits future edits
	# if the user starts playtesting.
	# (CONNECT_ONE_SHOT does no good here--manual cleanup from within _end_edit
	#  is still needed for other cases. More details in _end_edit.)
	main.playtest_started.connect(Callable(self, "_end_edit").bind(true))
	
	# Create a world-space copy of the polygon's points array.
	var data: Array[Vector2] = [] # type hint required so inner begin_edit works
	for point in obj_to_edit.polygon:
		data.append(point + obj_to_edit.position)
	
	drawable_polygon.begin_edit(data)


func _end_edit(save: bool):
	# Can't end editing a polygon if we're not already editing a polygon.
	if main.editor_state != main.EDITOR_STATE.POLYGON_EDIT:
		return
	
	main.editor_state = main.EDITOR_STATE.IDLE
	
	# Copy needed data out of the drawable.
	var polygon_data = PackedVector2Array(drawable_polygon.readonly_local_polygon)
	var polygon_position = drawable_polygon.global_position
	# Drawable is done now.
	drawable_polygon.end_edit()
	
	# Write edited polygon to the target node if needed.
	if save:
		main.polygon_edit_node.position = polygon_position
		main.polygon_edit_node.polygon = polygon_data
	
	# Re-show the hidden target node.
	main.polygon_edit_node.visible = true
	
	# Disconnect the apply-on-playtest callback.
	# (Using CONNECT_ONE_SHOT at callback register time does no good here--
	#  because _end_edit can be called without invoking the callback. Then
	#  the callback isn't emitted, doesn't disconnect anything, and when the
	#  playtest starts, _end_edit gets called outside of a poly-edit operation.
	#  As such, either way manual cleanup is required for tidiness.)
	# (This fn is currently set up to self-abort in that case, but
	#  practicing callback hygiene is never wrong.)
	main.playtest_started.disconnect(Callable(self, "_end_edit"))


func add_vertex(at_position: Vector2, at_index: int):
	print("New at ", at_position, ", index ", at_index)
	# Update the drawable's polygon.
	drawable_polygon.polygon.insert(at_index, drawable_polygon.position + at_position)
	# Awkwardly enough, the drawable won't run its update-on-change code when
	# polygon is modified instead of set fresh. Run it manually instead.
	drawable_polygon.refresh_polygon()
	_refresh_display_polygon()
	_begin_move_vertex(at_index)


func remove_vertex(index):
	print("Remove ", index)
	# Check if there'll be enough verts left without this one to still form
	# a polygon.
	if drawable_polygon.polygon.size() <= 3:
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
		_refresh_display_polygon()


func _begin_move_vertex(index):
	print("Moving ", index)
	main.editor_state = main.EDITOR_STATE.POLYGON_DRAG_VERTEX
	dragging_index = index
	
	drawable_polygon.begin_drag()


## Deletes the entire polygon.
func delete_polygon():
	_end_edit(false)
	main.polygon_edit_node.queue_free()
	
	polygon_deleted.emit(main.polygon_edit_node)


func _refresh_display_polygon():
	if !main.polygon_edit_node: return
	main.polygon_edit_node.polygon = drawable_polygon.readonly_local_polygon
	main.polygon_edit_node.position = drawable_polygon.global_position


## Temp function which hooks up to 
func _demo_press():
	_begin_create()
