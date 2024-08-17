extends Control

@onready var checkmark: Sprite2D = $Button/Checkmark
@onready var parent_menu: Panel = $"../.."
@onready var label: Label = $Label 

var pressed: bool = false

func _ready() -> void: 
	checkmark.frame = 1

func _on_Button_pressed() -> void:
	pressed = !pressed
	checkmark.visible = pressed

	# Do aesthetic effects in response to the button press.
	if pressed: 
		Singleton.get_node("SFX/Confirm").play()
	else: 
		Singleton.get_node("SFX/Back").play()
	
	parent_menu.on_value_changed(label.text, pressed)
