@tool
extends Area2D

@export var sweep_direction: Vector2
@export var spawn_location: Vector2
@export var scene_path: String
@export var size: Vector2: set = set_size

@onready var sweep_effect: Warp = $"/root/Singleton/Warp"
@onready var player = $"/root/Main/Player"


func set_size(new_size):
	$CollisionShape2D.shape.size = new_size
	size = new_size


func _on_WarpZone_body_entered(_body):
	if sweep_effect.enter != 1:
		sweep_effect.warp(sweep_direction, spawn_location, scene_path)
