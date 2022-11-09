extends Label


func _on_SizeUp_pressed():
	TouchControls.button_scale += 1


func _on_SizeDown_pressed():
	TouchControls.button_scale = max(TouchControls.button_scale - 1, 2)
