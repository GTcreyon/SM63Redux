extends Button

onready var dialog = $"/root/Main/UILayer/OpenDialog"


func _on_Open_pressed():
	dialog.popup_centered_ratio(0.75)
