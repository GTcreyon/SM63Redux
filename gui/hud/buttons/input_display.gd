extends AnimatedSprite

export(String) var input

var intensity = 0

func _physics_process(_delta):
	intensity = max(intensity - 0.05, 0)
	if Input.is_action_pressed(input):
		animation = "on"
		if Input.is_action_just_pressed(input):
			intensity = 1
	else:
		animation = "off"
	material.set_shader_param("outline_color", Color(1, 1, 1, intensity))
