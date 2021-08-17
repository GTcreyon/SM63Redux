extends Area2D

onready var gui = $"/root/Main/Player/Camera2D/GUI"
onready var player = $"/root/Main/Player"
export(Array, String, MULTILINE) var lines = [""]

func _process(_delta):
	if Input.is_action_just_pressed("interact") && overlaps_body(player):
		gui.load_lines(lines)
