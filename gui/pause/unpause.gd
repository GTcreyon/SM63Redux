extends Control

onready var parent = $".."

func _init():
	visible = false
	if OS.get_name() == "Android":
		visible = true


func _ready():
	rect_scale = Vector2.ONE * max(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1) * 2


func _on_Unpause_pressed():
	if !Singleton.feedback && parent.modulate.a >= 1:
		Input.action_press("pause")


func _on_Unpause_released():
	if !Singleton.feedback && parent.modulate.a >= 1:
		Input.action_release("pause")
