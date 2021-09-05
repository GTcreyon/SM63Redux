extends Area2D

onready var sweep_effect = $"/root/Main/Player/Camera2D/GUI/SweepEffect" 
export var set_location : Vector2
export var scene_path : String

#func _ready():
#	sweep_effect.rect_position.x = -800
#	sweep_effect.rect_position.y = 0


func _on_WarpZone_body_entered(_body):
	sweep_effect.visible = true
	sweep_effect.turn_on = true
	sweep_effect.set_location = set_location
	sweep_effect.scene_path = scene_path
