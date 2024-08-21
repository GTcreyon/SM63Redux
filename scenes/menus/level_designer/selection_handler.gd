class_name LDSelectionHandler
extends Control

signal selection_changed(rect: Rect2, new_selection: Array)

const TEXT_MIN_SIZE = Vector2(8, 8)
const alpha_bottom = 0.4
const alpha_top = 0.7
const alpha_speed = 0.2

var alpha_timer = 0
var start_position = Vector2.ZERO
var selection_rect = Rect2(Vector2.ZERO, Vector2.ZERO)
var selection_hit = []

@onready var main = $"/root/Main"
@onready var property_menu: LDPropertyMenu = $"/root/Main/UILayer/PropertyMenu"
@onready var camera = $"/root/Main/Camera"
@onready var hover = $Hover
@onready var buttons = $Buttons
@onready var polygon_edit_button = $Buttons/Polygon


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
	hover.global_position = selection_rect.position
	hover.size = selection_rect.size
	
	selection_rect.position += Vector2(1, 1)
	selection_rect.size -= Vector2(2, 2)


func _unhandled_input(event):
	# Open properties
	
	if event.is_action_pressed("ld_open_properties") and len(selection_hit) == 1:
		if property_menu.visible:
			property_menu.hide_menu()
			accept_event()
		else:
			property_menu.set_properties(selection_hit[0])
			property_menu.show_menu()
			accept_event()
		
	if event.is_action_pressed("ld_delete"):
		start_position = Vector2.ZERO
		hover.visible = false
		buttons.visible = false
		
		for item in selection_hit:
			item.queue_free()
		selection_hit = []
		main.editor_state = main.EDITOR_STATE.IDLE
		
		selection_changed.emit(selection_rect, selection_hit)
	
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
		_on_release()
		main.editor_state = main.EDITOR_STATE.IDLE
		accept_event()


func is_a_polygon_item(item: Node) -> bool:
	if !item:
		return false
	if !item.get_parent():
		return false
	var parent_name = item.get_parent().name
	return parent_name == "Terrain" or parent_name == "Water" or parent_name == "CameraLimits"


func _on_polygon_deleted(polygon: Polygon2D):
	# Remove the now-deleted polygon from the selection.
	# Currently it's not possible to open the polygon editor if there's
	# more than just one terrain lump selected, but if we ever implement
	# multi-edit, we'll want more selective logic than just deselect-all.
	remove_from_selection(polygon)


## Sets the selection to the given item or array of items. The previous
## selection will be cleared.
func set_selection(item):
	# Remove the glow from the previous selection before we clear it.
	for hit in selection_hit:
		hit.set_glowing(false)
	
	# Wipe selection.
	selection_hit = []
	# Fall through to this function, because it does everything we need.
	add_to_selection(item)


## Adds the given item or array of items to the existing selection.
func add_to_selection(item):
	# If the item is singular, wrap it into an array.
	# That way we only need to write an array execution path.
	var items = item if item is Array else [item]
	
	# Add the item(s) to the selection.
	selection_hit.append_array(items)
	
	# Make them all glow to show their selected status.
	for hit in items:
		hit.set_glowing(true)
	
	_update_button_visibility()
	
	selection_changed.emit(selection_rect, selection_hit)


## Removes the given item or array of items from the selection. If the selection
## does not contain the given item(s), nothing happens.
func remove_from_selection(item):
	# If the item is singular, wrap it into an array.
	# That way we only need to write an array execution path.
	var items = item if item is Array else [item]
	
	for hit in items:
		# Remove the item from the selection.
		# (TODO: repeatedly calling erase() could be slow. If it needs opti,
		#  then for large arrays, might it be faster to compute the
		#  complementary set of "items," then call set_selection()?)
		selection_hit.erase(hit)
		# Disable selected-item glow since they're no longer selected.
		hit.set_glowing(false)
	
	_update_button_visibility()
	
	selection_changed.emit(selection_rect, selection_hit)


## Clears the selection.
func deselect_all():
	for hit in selection_hit:
		hit.set_glowing(false)
	
	selection_hit = []
	
	buttons.visible = false
	
	selection_changed.emit(selection_rect, selection_hit)


func _update_button_visibility():
	# Show the buttons if there's anything in this selection.
	buttons.visible = len(selection_hit) != 0
	# If the buttons are visible now, put them where they should be.
	if buttons.visible:
		buttons.global_position = main.get_snapped_mouse_position() + Vector2(
			-buttons.size.x / 2,
			4
		)
	# If the selection consists of exactly one (1) terrain lump or other
	# polygon item, show the polygon edit button.
	polygon_edit_button.visible = len(selection_hit) == 1 and is_a_polygon_item(selection_hit[0])


# Return how many items were selected by the previous selection
# The function is named `calculate` because it does collision detection calculations which can be pretty expensive
func _calculate_selected(max_selected = 32) -> Array:
	var collision_handler = get_world_2d().direct_space_state
	
	var hitboxes = []
	if (selection_rect.size.length() > 8):
		# Welcome to this horrible boilerplate rectangle collision detection!
		# Godot pls fix
		var shape = RectangleShape2D.new()
		shape.size = selection_rect.size
		var query = PhysicsShapeQueryParameters2D.new()
		query.collide_with_areas = true
		query.collide_with_bodies = true
		query.set_shape(shape)
		query.transform = Transform2D(0, selection_rect.position + selection_rect.size / 2) # Calculate the center
		hitboxes = collision_handler.intersect_shape(query, max_selected)
	else:
		# Good news! 4.1 extended the same design to points~
		var query = PhysicsPointQueryParameters2D.new()
		query.position = selection_rect.position
		query.collision_mask = 0b0111_1111_1111_1111_1111_1111_1111_1111
		query.collide_with_bodies = true
		query.collide_with_areas = false
		hitboxes = collision_handler.intersect_point(query, max_selected)
	
	# Convert from raw hitboxes to the actual items
	var hit_items = []
	for hitbox in hitboxes:
		hitbox = hitbox.collider
		# Find the top most parent of the collider
		# This isn't guaranteed to be just get_parent() as the collider can be nested in several children
		while hitbox.get_parent():
			hitbox = hitbox.get_parent()
			var parent = hitbox.get_parent()
			if is_a_polygon_item(hitbox) or parent.name == "Items":
				hit_items.append(hitbox)
				break
	return hit_items


func _on_release():
	# Set selection from what's in the hover region.
	set_selection(_calculate_selected())
