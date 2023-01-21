extends Button
# A button on the pause menu that selects which menu is active

var scroll = 0
var scroll_goal = 0

onready var stars = $Stars
onready var text_node = $Text
onready var buttons = [get_parent().get_node("ButtonMap"), get_parent().get_node("ButtonFludd"), get_parent().get_node("ButtonOptions"), get_parent().get_node("ButtonExit")]

export var texture_off: StreamTexture
export var texture_on: StreamTexture


func _process(delta):
	var dmod = 60 * delta
	
	# Ensure we don't block other clicks while invisible
	if modulate.a <= 0:
		mouse_filter = MOUSE_FILTER_IGNORE
	else:
		mouse_filter = MOUSE_FILTER_STOP
	
	# Change which star polygon is visible
	if pressed:
		stars.texture = texture_on
	else:
		stars.texture = texture_off
	
	if pressed:
		scroll = fmod((scroll + 0.01 * dmod), 1.0)
		scroll_goal = 0
	elif is_hovered():
		scroll = fmod((scroll + 0.02 * dmod), 1.0)
		scroll_goal = 0
	else:
		if scroll_goal == 0:
			if scroll > 0.5:
				scroll_goal = 2
			else:
				scroll_goal = 1
		elif scroll_goal == 1:
			scroll = lerp(scroll, 1, 0.02)
		else:
			scroll = lerp(scroll, 1, 0.04)
	
	stars.texture_offset = Vector2(-15, -10) * scroll + Vector2(0, -2)


# Adjust the star polygon to match the size of the button
func resize():
	stars.polygon[1].x = rect_size.x - 1
	stars.polygon[2].x = rect_size.x - 1


func _on_Button_toggled(button_pressed):
	if button_pressed:
		# Move the text down by one to make it look pressed down
		text_node.margin_top = -7
		
		# Unpress all other buttons
		for button in buttons:
			if button != self:
				button.pressed = false
	else:
		text_node.margin_top = -8
