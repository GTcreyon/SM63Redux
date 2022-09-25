extends Control

signal selection_changed

onready var main = $"/root/Main"
onready var property_menu = $"/root/Main/UILayer/PropertyMenu"
onready var camera = $"/root/Main/Camera"
onready var hover = $Hover
onready var buttons = $Buttons

const TEXT_MIN_SIZE = Vector2(8, 8)
const alpha_bottom = 0.4
const alpha_top = 0.7
const alpha_speed = 0.2

var alpha_timer = 0
var start_position = Vector2.ZERO
var selection_rect = Rect2(Vector2.ZERO, Vector2.ZERO)
var selection_hit = []

# Return how many items were selected by the previous selection
# The function is named `calculate` because it does collision detection calculations which can be pretty expensive
func calculate_selected(max_selected = 32):
	var collision_handler = get_world_2d().direct_space_state
	
	var hitboxes = []
	if (selection_rect.size.length() > 8):
		# Welcome to this horrible boilerplate rectangle collision detection!
		# Godot pls fix
		var shape = RectangleShape2D.new()
		shape.set_extents(selection_rect.size / 2) # Extends is both ways, hence / 2
		var query = Physics2DShapeQueryParameters.new()
		query.collide_with_areas = true
		query.collide_with_bodies = true
		query.set_shape(shape)
		query.transform = Transform2D(0, selection_rect.position + selection_rect.size / 2) # Calculate the center
		hitboxes = collision_handler.intersect_shape(query, max_selected)
	else:
		hitboxes = collision_handler.intersect_point(selection_rect.position, max_selected, [], 0x7FFFFFFF, true, true)
	
	# Convert from raw hitboxes to the actual items
	var hit = []
	for hitbox in hitboxes:
		hitbox = hitbox.collider
		# Find the top most parent of the collider
		# This isn't guaranteed to be just get_parent() as the collider can be nested in several children
		while hitbox.get_parent():
			hitbox = hitbox.get_parent()
			var parent_name = hitbox.get_parent().name
			if parent_name == "Items" or parent_name == "Terrain" or parent_name == "Water" or parent_name == "CameraLimits":
				hit.append(hitbox)
				break
	return hit

func on_release():
	# Remove the effect of previous selection
	for hit in selection_hit:
		hit.set_glowing(false)
	
	# Get the new selection & give them the hover effect
	selection_hit = calculate_selected()
	for hit in selection_hit:
		hit.set_glowing(true)
	
	buttons.visible = len(selection_hit) != 0
	if buttons.visible:
		buttons.rect_global_position = main.get_snapped_mouse_position() + Vector2(
			-buttons.rect_size.x / 2,
			4
		)
	
	emit_signal("selection_changed", selection_rect, selection_hit)

func _unhandled_input(event):
	# Open properties
	if event.is_action_pressed("ld_open_properties") and len(selection_hit) == 1:
		if property_menu.visible:
			property_menu.hide()
			accept_event()
		else:
			property_menu.set_properties(selection_hit[0].properties, selection_hit[0])
			property_menu.show()
			accept_event()
		
	if event.is_action_pressed("ld_delete"):
		start_position = Vector2.ZERO
		hover.visible = false
		buttons.visible = false
		
		for item in selection_hit:
			item.queue_free()
		selection_hit = []
		main.editor_state = main.EDITOR_STATE.IDLE
		emit_signal("selection_changed", selection_rect, selection_hit)
	
	# Handle starting/ending selecting
	if event.is_action_pressed("ld_select") and main.editor_state == main.EDITOR_STATE.IDLE:
		start_position = main.get_snapped_mouse_position()
		alpha_timer = 0
		hover.visible = true
		main.editor_state = main.EDITOR_STATE.SELECTING
		accept_event()
	if event.is_action_released("ld_select") and main.editor_state == main.EDITOR_STATE.SELECTING:
		start_position = Vector2.ZERO
		hover.visible = false
		on_release()
		main.editor_state = main.EDITOR_STATE.IDLE
		accept_event()

func _process(dt):
	if !Input.is_action_pressed("ld_select"):
		return
	if !visible:
		return
	
	# Fading alpha effect
	alpha_timer += dt * alpha_speed
	hover.modulate.a = alpha_bottom + abs(
		2 * fmod(
			alpha_timer,
			alpha_top - alpha_bottom
		) - (alpha_top - alpha_bottom)
	)
	
	# Update the selection rectangle
	var target_size = main.get_snapped_mouse_position() - start_position
	selection_rect.position = start_position + Vector2( min(0, target_size.x), min(0, target_size.y) )
	target_size.x = max(TEXT_MIN_SIZE.x, abs(target_size.x))
	target_size.y = max(TEXT_MIN_SIZE.y, abs(target_size.y))
	selection_rect.size = target_size
	
	# Update the actual selection visuals
	hover.rect_global_position = selection_rect.position
	hover.rect_size = selection_rect.size
	
	selection_rect.position += Vector2(1, 1)
	selection_rect.size -= Vector2(2, 2)
	
