extends Button

onready var dialog = $"/root/Main/UILayer/SaveDialog"


func _on_File_pressed():
	dialog.popup_centered_ratio(0.75)
