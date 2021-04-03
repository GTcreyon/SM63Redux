tool
extends Node2D

export(int, 3) var type = 0
var old_type = type

onready var main = $"/root/Main/Items"
onready var hover = $Hover
onready var rocket = $Rocket
onready var turbo = $Turbo

var obj = preload("res://actors/items/fludd_box/fludd.tscn").instance()

func switch_type(new_type):
	match new_type:
		2:
			hover.visible = false
			rocket.visible = false
			turbo.visible = true
		1:
			hover.visible = false
			rocket.visible = true
			turbo.visible = false
		_:
			hover.visible = true
			rocket.visible = false
			turbo.visible = false


func _process(_delta):
	if Engine.editor_hint:
		if type != old_type: #reduces number of checks each frame by checking if the variable changed
			switch_type(type)
			old_type = type

func _ready():
	switch_type(type)


func _on_FluddBox_body_entered(body):
	if body.global_position.y < global_position.y && (body.global_position.x < global_position.x || body.global_position.x > global_position.x):
		print("collided from top")
		main.call_deferred("add_child", obj)
		obj.position = position
		$"/root/Main/Player".vel.y = -6 * 32 / 60
		queue_free()
	pass # Replace with function body.
