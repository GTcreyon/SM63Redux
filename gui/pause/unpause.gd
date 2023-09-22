extends Control

@onready var parent = $".."

func _init():
	visible = false


func _process(_delta):
	visible = Singleton.touch_control


func _on_Unpause_button_up():
	if !Singleton.meta_pauses["feedback"] and parent.modulate.a >= 1:
		Input.action_release("pause")


func _on_Unpause_button_down():
	if !Singleton.meta_pauses["feedback"] and parent.modulate.a >= 1:
		Input.action_press("pause")
