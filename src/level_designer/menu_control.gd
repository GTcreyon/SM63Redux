extends Node2D

onready var ld_camera := $"../LDCamera"
onready var save_controls := $SaveControl

func _ready():
	pass # Replace with function body.

func _process(_dt):
	position = ld_camera.position

func _on_terrain_control_place_pressed():
	print("Place Terrain")
	pass # Replace with function body.
