extends Button

var scroll = 0
var scroll_goal = 0

onready var stars_on = $StarsOn
onready var stars_off = $StarsOff
onready var text_node = $Text
onready var buttons = [get_parent().get_node("ButtonMap"), get_parent().get_node("ButtonFludd"), get_parent().get_node("ButtonOptions"), get_parent().get_node("ButtonExit")]

func _process(_delta):
	if pressed:
		stars_on.visible = true
		stars_off.visible = false
	else:
		stars_on.visible = false
		stars_off.visible = true
	if pressed:
		scroll = fmod((scroll + 0.01), 1.0)
		scroll_goal = 0
	elif is_hovered():
		scroll = fmod((scroll + 0.02), 1.0)
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
	stars_off.texture_offset = Vector2(-15, -10) * scroll + Vector2(0, -2)
	stars_on.texture_offset = stars_off.texture_offset


func _on_Button_toggled(button_pressed):
	if button_pressed:
		text_node.margin_top = -7
		for button in buttons:
			if button != self:
				button.pressed = false
	else:
		text_node.margin_top = -8
