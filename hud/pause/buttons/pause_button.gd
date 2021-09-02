extends Button

var scroll = 0
var scroll_goal = 0

func _process(_delta):
	if pressed:
		$StarsOn.visible = true
		$StarsOff.visible = false
	else:
		$StarsOn.visible = false
		$StarsOff.visible = true
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
	$StarsOff.texture_offset = Vector2(-15, -10) * scroll + Vector2(0, -2)
	$StarsOn.texture_offset = $StarsOff.texture_offset


func _on_Button_toggled(button_pressed):
	if button_pressed:
		$Text.margin_top = -7
	else:
		$Text.margin_top = -8
