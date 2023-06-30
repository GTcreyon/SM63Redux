class_name Tickbox
extends Control

var pressed: bool = false

@onready var sprite = $Sprite2D


func _on_Tickbox_pressed():
	pressed = !pressed
	_play_press_anim()
	if pressed:
		Singleton.get_node("SFX/Confirm").play()
	else:
		Singleton.get_node("SFX/Back").play()


func _play_press_anim():
	sprite.playing = pressed
	sprite.frame = 0


func set_pressed(new_val: bool):
	pressed = new_val
	if pressed:
		sprite.frame = 2
	else:
		sprite.frame = 0
