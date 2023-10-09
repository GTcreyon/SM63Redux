extends Control

var pressed = false

@onready var sprite = $Button/Sprite2D
@onready var label = $Label
@onready var parent_menu = $"../.."

func _ready():
	if pressed:
		sprite.animation = "checked"
		# Skip past animation bit, straight to the sustained frame.
		sprite.frame = 1


func _on_Button_pressed():
	pressed = !pressed

	# Do aesthetic effects in response to the button press.
	if pressed:
		Singleton.get_node("SFX/Confirm").play()
		sprite.animation = "checked"
		sprite.play()
	else:
		Singleton.get_node("SFX/Back").play()
		sprite.animation = "unchecked"

	parent_menu.on_value_changed(label.text, pressed)
