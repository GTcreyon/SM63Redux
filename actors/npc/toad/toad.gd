tool
extends Area2D

export(Array, String, MULTILINE) var lines = [""]

onready var player = $"/root/Main/Player"
onready var dialog = $"/root/Main/Player/Camera2D/GUI/DialogBox"

const spot_presets = [
	[ #red
		Color("df6042"),
		Color("b64728"),
	],
	[ #green
		Color("9cc56d"),
		Color("597b5c"),
	],
	[ #blue
		Color("5f75c5"),
		Color("443695"),
	],
	[ #yellow
		Color("f7c55f"),
		Color("e59f53"),
	],
	[ #purple
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

export(int, "red", "green", "blue", "yellow", "purple") var spot = 0 setget set_spot
export(int, 1) var skin = 0 setget set_skin
var temp_skin
var temp_spot

func _init():
	temp_skin = skin
	temp_spot = spot

func set_spot(new_spot):
	for i in range(2):
		material.set_shader_param("color" + str(i), spot_presets[new_spot][i])
	spot = new_spot
	temp_spot = new_spot

func set_skin(new_skin):
	for i in range(4):
		material.set_shader_param("color" + str(i + 2), skin_presets[new_skin][i])
	skin = new_skin
	temp_skin = new_skin


func _ready():
	$Sprite.frame = fmod(position.x + position.y * PI, 7)


func _physics_process(_delta):
	if !Engine.editor_hint:
		if Input.is_action_just_pressed("interact") && overlaps_body(player) && player.state == player.s.walk && player.sign_cooldown <= 0:
			#player.switch_anim("back")
			player.vel = Vector2.ZERO
			player.sign_x = position.x - 16
			player.locked = true
			player.sign_cooldown = 1
			dialog.load_lines(lines)
