class_name Toad
extends InteractableDialog

const spot_presets = [
	[ # Red
		Color("df6042"),
		Color("b64728"),
	],
	[ # Green
		Color("9cc56d"),
		Color("597b5c"),
	],
	[ # Blue
		Color("5f75c5"),
		Color("443695"),
	],
	[ # Yellow
		Color("f7c55f"),
		Color("e59f53"),
	],
	[ # Purple
		Color("c779db"),
		Color("955fc5"),
	],
]

const skin_presets = [
	[
		Color("fbd395"),
		Color("e59f53"),
		Color("df6042"),
		Color("b64728"),
	],
	[
		Color("e59f53"),
		Color("df6042"),
		Color("df6042"),
		Color("b64728"),
	],
]

@export_enum("Red", "Green", "Blue", "Yellow", "Purple") var spot: int = 0
@export_range(0, 1) var skin: int = 0


func set_spot(new_spot):
	for i in range(2):
		material.set_shader_parameter("color" + str(i), spot_presets[new_spot][i])


func set_skin(new_skin):
	for i in range(4):
		material.set_shader_parameter("color" + str(i + 2), skin_presets[new_skin][i])


func _init():
	material = material.duplicate()
	set_spot(spot)
	set_skin(skin)


func _ready():
	sprite.frame = fmod(position.x + position.y * PI, 7)
	sprite.play()

