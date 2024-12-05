class_name Sign
extends InteractableDialog

@onready var sfx_open: AudioStreamPlayer = $Open
@onready var glow_check: Area2D = $GlowCheck

var pulse: float = 0.0


func _ready():
	# Duplicate materials since Godot 4.1 is missing instance shader uniforms
	# and using resource_local_to_scene makes things hard to edit
	material = material.duplicate()


func _process(delta):
	var glow_factor = 0
	for body in glow_check.get_overlapping_bodies():
		glow_factor = max(max((100 - position.distance_to(body.position)) / 50, 0), glow_factor)
	
	pulse += 0.1 * delta * 60
	material.set_shader_parameter("outline_color", Color(1, 1, 1, (sin(pulse) * 0.25 + 0.5) * glow_factor))


func _interact_with(body):
	super._interact_with(body)
	sfx_open.play()
