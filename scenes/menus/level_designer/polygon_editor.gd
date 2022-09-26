extends Control

onready var main = $"/root/Main"
onready var drawable_polygon = $Polygon

func _unhandled_input(event):
	if event.is_action_pressed("ld_cancel_placement"):
		quit_creating(false)
	
	if event.is_action_pressed("ld_place") and main.editor_state == main.EDITOR_STATE.POLYGON_CREATE:
		drawable_polygon.polygon = drawable_polygon.polygon + [main.get_snapped_mouse_position()]
		if len(drawable_polygon.polygon) >= 3 and !Input.is_action_pressed("ld_keep_place"):
			quit_creating(true)

func quit_creating(save):
	main.editor_state = main.EDITOR_STATE.IDLE
	drawable_polygon.polygon = []
	drawable_polygon.should_connector_be_transparent = false
	drawable_polygon.should_draw_predict_line = false
	drawable_polygon.should_have_buttons = false
	
	if save:
		# TODO
		pass

func start_polygon_creation():
	if main.editor_state != main.EDITOR_STATE.IDLE:
		return
	main.editor_state = main.EDITOR_STATE.POLYGON_CREATE
	
	drawable_polygon.polygon = []
	drawable_polygon.should_connector_be_transparent = true
	drawable_polygon.should_draw_predict_line = true
	drawable_polygon.should_have_buttons = false
	

func _demo_press():
	start_polygon_creation()
