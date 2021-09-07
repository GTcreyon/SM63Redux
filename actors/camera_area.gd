tool
extends Area2D

export(int, FLAGS, "Left", "Right", "Up", "Down") var limits
export var size : Vector2 setget set_size
onready var cam = $"/root/Main/Player/Camera2D"

func set_size(new_size):
	$CollisionShape2D.shape.extents = new_size / 2
	size = new_size


func _on_Area2D_body_entered(_body):
	if !Engine.editor_hint:
		if limits & 1:
			$"/root/Main/Player/Camera2D".limit_right = position.x + $CollisionShape2D.shape.extents.x
		if limits & 2:
			$"/root/Main/Player/Camera2D".limit_left = position.x - $CollisionShape2D.shape.extents.x
		if limits & 4:
			$"/root/Main/Player/Camera2D".limit_bottom = position.y + $CollisionShape2D.shape.extents.y
		if limits & 8:
			$"/root/Main/Player/Camera2D".limit_top = position.y - $CollisionShape2D.shape.extents.y
