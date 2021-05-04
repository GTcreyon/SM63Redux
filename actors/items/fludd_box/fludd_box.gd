tool
extends Node2D

export(int, 3) var type = 0
var old_type = type

onready var main = $"/root/Main/Items"
onready var player = $"/root/Main/Player"
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
	if body == player && player.vel.y > 1:
		main.call_deferred("add_child", obj)
		obj.position = position
		player.vel.y = -6 * 32 / 60
		queue_free()
