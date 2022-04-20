extends Area2D

onready var dialog = $"/root/Main/Player/Camera2D/GUI/DialogBox"
onready var player = $"/root/Main/Player"
onready var sfx_open = $Open

export(Array, String, MULTILINE) var lines = [""]

var pulse = 0.0
var glow_factor = 0.0

func _physics_process(_delta):
	if player != null:
		glow_factor = max((100 - position.distance_to(player.position)) / 50, 0)
	pulse += 0.1
	material.set_shader_param("outline_color", Color(1, 1, 1, (sin(pulse) * 0.25 + 0.5) * glow_factor))
	var bodies = get_overlapping_bodies()
	if Input.is_action_just_pressed("interact") && bodies.size() > 0 && (bodies[0].state == bodies[0].s.walk || bodies[0].state == bodies[0].s.spin) && bodies[0].sign_cooldown <= 0:
		sfx_open.play()
		bodies[0].switch_anim("back")
		bodies[0].vel = Vector2.ZERO
		bodies[0].sign_x = position.x
		bodies[0].static_v = true
		bodies[0].sign_cooldown = 1
		dialog.load_lines(lines)
