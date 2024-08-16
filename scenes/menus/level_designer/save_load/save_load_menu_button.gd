extends Button
## A button which can open a save or load dialog when triggered via signal.

@export var dialog: FileDialog


func open_dialog():
	dialog.popup_centered_ratio(0.75)
