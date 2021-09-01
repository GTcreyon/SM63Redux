extends Button


func _on_Button_toggled(button_pressed):
	if button_pressed:
		$Text.margin_top = -7
	else:
		$Text.margin_top = -8
