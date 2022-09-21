extends TextureRect

onready var camera: Camera2D = $"/root/Main/Camera"

func _ready():
	$"../BGParent".modulate = Color(0.7, 0.7, 0.7)

func _process(_dt):
	material.set_shader_param("camera_position", camera.position)
