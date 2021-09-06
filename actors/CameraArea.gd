tool
extends Area2D

export var size : Vector2 setget set_size
onready var cam = $"/root/Main/Player/Camera2D"

func set_size(new_size):
	$CollisionShape2D.shape.extents = new_size / 2
	if !Engine.editor_hint:
		$"/root/Main/Player/Camera2D".limit_right = position.x + $CollisionShape2D.shape.extents.x
		$"/root/Main/Player/Camera2D".limit_left = position.x - $CollisionShape2D.shape.extents.x
	size = new_size
