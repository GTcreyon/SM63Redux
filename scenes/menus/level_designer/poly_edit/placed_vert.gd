class_name PlacedVertex
extends TextureButton
## Widget for editing a placed polygon-editor vertex.

# Thanks Dave and myyk for the initial implementation!
# https://stackoverflow.com/questions/66090893/how-can-i-extend-godots-button-to-distinguish-left-click-vs-right-click-events

## Signal emitted only when the button is left-clicked.
signal pressed_left
## Signal emitted only when the button is right-clicked.
signal pressed_right

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		# Set mouse-over cursor shape to click indicator on RMB-down events;
		# otherwise, set to move indicator.
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		else:
			mouse_default_cursor_shape = Control.CURSOR_MOVE
		
		# Emit click events if the mouse is on the button.
		if is_hovered():
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					# Respond to left clicks on press, for a drag-and-drop-like
					# user experience.
					if event.pressed:
						pressed_left.emit()
				MOUSE_BUTTON_RIGHT:
					# Respond to right clicks only on release, to allow the user a
					# moment to change their mind before vertex deletion.
					if !event.pressed:
						pressed_right.emit()
