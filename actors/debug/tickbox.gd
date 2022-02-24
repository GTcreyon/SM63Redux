extends Control

onready var sprite = $Sprite
var pressed = false

func _on_Button_pressed():
	pressed = !pressed
	sprite.playing = pressed
	sprite.frame = 0
