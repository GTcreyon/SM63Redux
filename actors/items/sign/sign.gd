extends Area2D

onready var dialog = $"/root/Main/Player/Camera2D/GUI/DialogBox"
onready var player = $"/root/Main/Player"
export(Array, String, MULTILINE) var lines = [""]

var pulse = 0.0
var glow_factor = 0.0

func _process(_delta):
	glow_factor = max((100 - position.distance_to(player.position)) / 50, 0)
	pulse += 0.1
	material.set_shader_param("outline_color", Color(1, 1, 1, (sin(pulse) * 0.25 + 0.5) * glow_factor))
	if Input.is_action_just_pressed("interact") && overlaps_body(player) && player.state == player.s.walk && player.sign_cooldown <= 0:
		player.switch_anim("back")
		player.vel = Vector2.ZERO
		player.sign_x = position.x
		player.static_v = true
		player.sign_cooldown = 1
		dialog.load_lines(lines)
