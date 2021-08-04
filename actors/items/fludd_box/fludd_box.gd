tool
extends Node2D

export(int, 2) var type = 0 setget set_type

onready var main = $"/root/Main/Items"
onready var player = $"/root/Main/Player"

var obj = preload("res://actors/items/fludd_box/fludd.tscn").instance()

func set_type(new_type):
	type = new_type
	match new_type:
		2:
			$Hover.visible = false
			$Rocket.visible = false
			$Turbo.visible = true
		1:
			$Hover.visible = false
			$Rocket.visible = true
			$Turbo.visible = false
		_:
			$Hover.visible = true
			$Rocket.visible = false
			$Turbo.visible = false


func _on_FluddBox_body_entered(body):
	if body == player && player.vel.y > 1:
		main.call_deferred("add_child", obj)
		obj.position = Vector2(position.x, position.y + 8.5)
		obj.switch_type(type)
		player.vel.y = -6 * 32 / 60
		queue_free()
