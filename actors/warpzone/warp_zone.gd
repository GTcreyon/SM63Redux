extends Area2D

onready var sweep_effect = $"/root/Singleton/Warp" 
export var sweep_direction : Vector2
export var spawn_location : Vector2
export var scene_path : String


func _on_WarpZone_body_entered(_body):
	sweep_effect.warp(sweep_direction, spawn_location, scene_path)
