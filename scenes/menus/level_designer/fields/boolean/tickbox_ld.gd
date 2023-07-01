extends Control

@onready var sprite = $Button/Sprite2D
@onready var label = $Label
@onready var parent_menu = $"../.."
var pressed = false


func _ready():
	if pressed:
		sprite.frame = 2


func _on_Button_pressed():
	pressed = !pressed

	# Do aesthetic effects in response to the button press.
	sprite.frame = 0
	if pressed:
		Singleton.get_node("SFX/Confirm").play()
		sprite.play()
	else:
		Singleton.get_node("SFX/Back").play()
		sprite.stop()

	parent_menu.on_value_changed(label.text, pressed)
