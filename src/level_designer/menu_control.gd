extends Node2D

onready var ld_camera := $"../LDCamera"
onready var save_controls := $SaveControl
onready var background := $"../Background"

func _ready():
#	var tex = ImageTexture.new()
#	tex.create(OS.window_size.x, OS.window_size.y, Image.FORMAT_RGB8)
#	background.texture = tex
	pass

func _process(_dt):
	background.material.set_shader_param("camera_position", global_position)

func _on_terrain_control_place_pressed():
	print("Place Terrain")
	pass # Replace with function body.
