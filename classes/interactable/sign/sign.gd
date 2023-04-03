class_name Sign
extends InteractableDialog

onready var sfx_open: AudioStreamPlayer = $Open
onready var glow_check: Area2D = $GlowCheck

var pulse: float = 0.0


func _process(delta):
	var glow_factor = 0
	for body in glow_check.get_overlapping_bodies():
		glow_factor = max(max((100 - position.distance_to(body.position)) / 50, 0), glow_factor)
	
	pulse += 0.1 * delta * 60
	material.set_shader_param("outline_color", Color(1, 1, 1, (sin(pulse) * 0.25 + 0.5) * glow_factor))


func _state_check(body) -> bool:
	return (body.state == body.S.NEUTRAL or body.state == body.S.SPIN) and body.sign_frames <= 0


func _interact_with(body):
	._interact_with(body)
	sfx_open.play()
