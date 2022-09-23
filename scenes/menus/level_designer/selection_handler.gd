extends NinePatchRect

onready var main = $"../.."
onready var camera: Camera2D = main.get_node("Camera")
const TEXT_MIN_SIZE = Vector2(16, 16)
const alpha_bottom = 0.4
const alpha_top = 0.7
const alpha_speed = 0.2

var alpha_timer = 0
var start_position = Vector2.ZERO
var selection_rect = Rect2(Vector2.ZERO, Vector2.ZERO)

func get_mouse_position():
	return main.snap_vector(get_global_mouse_position() + camera.position)

func _unhandled_input(event):
	if event.is_action_pressed("ld_select"):
		start_position = get_mouse_position() - TEXT_MIN_SIZE / 2
		alpha_timer = 0
		visible = true
	if event.is_action_released("ld_select"):
		start_position = Vector2.ZERO
		visible = false

func _process(dt):
	if !Input.is_action_pressed("ld_select"):
		return
	if !visible:
		return
	
	# Fading alpha effect
	alpha_timer += dt * alpha_speed
	modulate.a = alpha_bottom + abs(
		2 * fmod(
			alpha_timer,
			alpha_top - alpha_bottom
		) - (alpha_top - alpha_bottom)
	)
	
	# Update the selection rectangle
	var target_size = get_mouse_position() - start_position
	selection_rect.position = start_position + Vector2(
		min(0, target_size.x),
		min(0, target_size.y)
	)
	target_size.x = -target_size.x + TEXT_MIN_SIZE.x if target_size.x < 0 else target_size.x
	target_size.y = -target_size.y + TEXT_MIN_SIZE.y if target_size.y < 0 else target_size.y
	selection_rect.size = Vector2(
		max(TEXT_MIN_SIZE.x, target_size.x),
		max(TEXT_MIN_SIZE.y, target_size.y)
	)
	
	# Update the actual selection visuals
	rect_global_position = selection_rect.position
	rect_size = selection_rect.size
	
