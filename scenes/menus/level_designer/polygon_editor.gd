extends Control

onready var main = $"/root/Main"
onready var drawable_polygon = $Polygon

func _unhandled_input(event):
	if event.is_action_released("ld_cancel_placement"):
		quit_creating(false)
	
	if event.is_action_released("ld_place") and main.editor_state == main.EDITOR_STATE.POLYGON_CREATE:
		drawable_polygon.polygon = drawable_polygon.polygon + [main.get_snapped_mouse_position()]
		if len(drawable_polygon.polygon) > 2 and !Input.is_action_pressed("ld_keep_place"):
			quit_creating(true)

func quit_creating(save):
	main.editor_state = main.EDITOR_STATE.IDLE
	var polygon_data = PoolVector2Array(drawable_polygon.readonly_local_polygon)
	var polygon_position = drawable_polygon.rect_global_position
	drawable_polygon.polygon = []
	drawable_polygon.should_connector_be_transparent = false
	drawable_polygon.should_draw_predict_line = false
	drawable_polygon.should_have_buttons = false
	
	if len(polygon_data) > 2 and save:
		if Geometry.is_polygon_clockwise(polygon_data):
			polygon_data.invert()
		
		polygon_data.append(polygon_data[0])
		var terrain = main.place_terrain(polygon_data)
		terrain.position = polygon_position

func start_polygon_creation():
	if main.editor_state != main.EDITOR_STATE.IDLE:
		return
	main.editor_state = main.EDITOR_STATE.POLYGON_CREATE
	
	drawable_polygon.polygon = []
	drawable_polygon.should_connector_be_transparent = true
	drawable_polygon.should_draw_predict_line = true
	drawable_polygon.should_have_buttons = false

func edit_polygon(obj_to_edit):
	if main.editor_state != main.EDITOR_STATE.IDLE:
		return
	main.editor_state = main.EDITOR_STATE.POLYGON_EDIT
	
	obj_to_edit.visible = false
	
	var data = []
	for vec in obj_to_edit.polygon:
		data.append(vec + obj_to_edit.position)
	
	drawable_polygon.polygon = data
	drawable_polygon.should_connector_be_transparent = false
	drawable_polygon.should_draw_predict_line = false
	drawable_polygon.should_have_buttons = true

func _demo_press():
	start_polygon_creation()
