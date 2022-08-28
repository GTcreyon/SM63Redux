extends Control

onready var sprite = $Button/Sprite
onready var label = $Label
onready var parent_menu = $"../.."
var pressed = false


func _ready():
	if pressed:
		sprite.frame = 2


func _on_Button_pressed():
	pressed = not pressed
	if pressed:
		Singleton.get_node("SFX/Confirm").play()
	else:
		Singleton.get_node("SFX/Back").play()
	sprite.playing = pressed
	sprite.frame = 0
	parent_menu.on_value_changed(label.text, pressed)
