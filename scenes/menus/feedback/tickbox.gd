extends Control

onready var sprite = $Sprite
var pressed = false

func _on_Tickbox_pressed():
	pressed = !pressed
	if pressed:
		Singleton.get_node("SFX/Confirm").play()
	else:
		Singleton.get_node("SFX/Back").play()
	sprite.playing = pressed
	sprite.frame = 0
