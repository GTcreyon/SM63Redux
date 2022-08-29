extends Control

onready var parent = $".."

func _init():
	visible = false


func _ready():
	rect_scale = Vector2.ONE * max(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1) * 2


func _process(_delta):
	visible = Singleton.touch_controls()


func _on_Unpause_pressed():
	if !Singleton.feedback and parent.modulate.a >= 1:
		Input.action_press("pause")


func _on_Unpause_released():
	if !Singleton.feedback and parent.modulate.a >= 1:
		Input.action_release("pause")
