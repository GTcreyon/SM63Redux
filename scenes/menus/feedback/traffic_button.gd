extends Button

@export var color: Color
var save_press = false


func _process(_delta):
	if pressed:
		if !save_press:
			modulate = color
			for button in get_parent().get_children():
				button.button_pressed = false
			pressed = true
			save_press = true
			Singleton.get_node("SFX/Next").play()
	else:
		modulate = Color.WHITE
		save_press = false

