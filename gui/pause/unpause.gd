extends Control

func _init():
	visible = false
	if OS.get_name() == "Android":
		visible = true


func _ready():
	rect_scale = Vector2.ONE * floor(OS.window_size.y / Singleton.DEFAULT_SIZE.y) * 2


func _on_Unpause_pressed():
	if !Singleton.feedback:
		Input.action_press("pause")


func _on_Unpause_released():
	if !Singleton.feedback:
		Input.action_release("pause")
