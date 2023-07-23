extends Control

@onready var main = $"/root/Main"
@onready var selection_handler = $".."
@onready var polygon_editor = $"../../PolygonEditor"

enum DRAG_TYPE { NONE, MOVE, DUPLICATE }

var drag_start = Vector2.ZERO
var prev_drag_position = Vector2.ZERO
var being_dragged = []
var drag_type = DRAG_TYPE.NONE


func _on_dragger_pressed():
	if main.editor_state != main.EDITOR_STATE.IDLE:
		return
	
	drag_start = main.get_snapped_mouse_position()
	prev_drag_position = drag_start
	being_dragged = selection_handler.selection_hit
	drag_type = DRAG_TYPE.MOVE
	main.editor_state = main.EDITOR_STATE.DRAGGING
	
	visible = false


func _on_duplicator_pressed():
	if main.editor_state != main.EDITOR_STATE.IDLE:
		return
	
	drag_start = main.get_snapped_mouse_position()
	prev_drag_position = drag_start
	
	being_dragged = []
	for original in selection_handler.selection_hit:
		var dupe = original.duplicate()
		original.get_parent().add_child(dupe)
		being_dragged.append(dupe)
	
	drag_type = DRAG_TYPE.DUPLICATE
	main.editor_state = main.EDITOR_STATE.DRAGGING
	
	visible = false


func _unhandled_input(event):
	if event.is_action_pressed("ld_place") and main.editor_state == main.EDITOR_STATE.DRAGGING:
		main.editor_state = main.EDITOR_STATE.IDLE
		visible = true
		global_position = main.get_snapped_mouse_position() + Vector2(
			-size.x / 2,
			4
		)
		
		if drag_type == DRAG_TYPE.DUPLICATE:
			# We make sure the selection handler also selects the newly duplicated objects
			if Input.is_action_pressed("ld_keep_place"):
				selection_handler.selection_hit.append_array(being_dragged)
			else:
				for item in being_dragged:
					item.set_glowing(false)
		
		being_dragged = []
		drag_type = DRAG_TYPE.NONE
		accept_event()


func _process(_dt):
	if len(being_dragged) == 0:
		return
	
	var mouse_pos = main.get_snapped_mouse_position()
	var delta = mouse_pos - prev_drag_position
	prev_drag_position = mouse_pos
	
	for item in being_dragged:
		item.position += delta
		item.properties["Position"] = item.position


func _on_polygon_pressed():
	if len(selection_handler.selection_hit) == 1:
		polygon_editor.edit_polygon(selection_handler.selection_hit[0])
