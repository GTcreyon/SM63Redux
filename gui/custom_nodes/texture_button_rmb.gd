class_name RMBTextureButton
extends TextureButton
## Texture button which can respond separately to each mouse button.
##
## The normal [signal pressed] signal is still emitted on click

# Thanks Dave and myyk for the initial implementation!
# https://stackoverflow.com/questions/66090893/how-can-i-extend-godots-button-to-distinguish-left-click-vs-right-click-events

## Signal emitted only when the button is left-clicked.
signal pressed_left
## Signal emitted only when the button is middle-clicked.
signal pressed_middle
## Signal emitted only when the button is right-clicked.
signal pressed_right

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		# Abort if the click event is not the one this button responds to.
		var action_occurred: bool
		match action_mode:
			ACTION_MODE_BUTTON_PRESS:
				action_occurred = event.pressed
			ACTION_MODE_BUTTON_RELEASE:
				action_occurred = !event.pressed
		if !action_occurred:
			return
		
		# We didn't abort. Emit the appropriate event for the button.
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				pressed_left.emit()
			MOUSE_BUTTON_MIDDLE:
				pressed_middle.emit()
			MOUSE_BUTTON_RIGHT:
				pressed_right.emit()
