extends Area2D

onready var dialog = $"/root/Main/Player/Camera2D/GUI/DialogBox"
onready var player = $"/root/Main/Player"
export(Array, String, MULTILINE) var lines = [""]

func _process(_delta):
	if Input.is_action_just_pressed("interact") && overlaps_body(player) && !player.static_v:
		player.static_v = true
		dialog.load_lines(lines)
