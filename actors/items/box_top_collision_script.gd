tool
extends Node2D

export(int, 3) var fludd_type = 0

onready var main = $"/root/Main/Items"
onready var fludd1 = $Box_Blue
onready var fludd2 = $Box_Red
onready var fludd3 = $Box_Gray

var testloaderobj = preload("res://actors/items/fludd.tscn")
var obj = testloaderobj.instance()

func switch_type(fludd_type):
	match fludd_type:
		0:
			fludd1.visible = false
			fludd1.monitoring = false
			fludd2.visible = false
			fludd2.monitorable = false
			fludd3.visible = false
			fludd3.monitoring = false
			
		1:
			fludd1.visible = true
			fludd1.monitoring = true
			fludd2.visible = false
			fludd2.monitorable = false
			fludd3.visible = false
			fludd3.monitoring = false
			
		2:
			fludd1.visible = false
			fludd1.monitoring = false
			fludd2.visible = true
			fludd2.monitorable = true
			fludd3.visible = false
			fludd3.monitoring = false
		
		3:
			fludd1.visible = false
			fludd1.monitoring = false
			fludd2.visible = false
			fludd2.monitorable = false
			fludd3.visible = true
			fludd3.monitoring = true
			
func _process(_delta):
	if Engine.editor_hint:
		switch_type(fludd_type)

func _ready():
	switch_type(fludd_type)


func _on_Box_Blue_body_entered(body):
	if body.global_position.y < global_position.y && (body.global_position.x < global_position.x || body.global_position.x > global_position.x):
		print("collided from top")
		main.add_child(obj)
		obj.position = position
		
		queue_free()
	pass # Replace with function body.


func _on_Box_Red_body_entered(body):
	if body.global_position.y < global_position.y && (body.global_position.x < global_position.x || body.global_position.x > global_position.x):
		print("collided from top")
		main.add_child(obj)
		obj.position = position
		
		queue_free()
	pass # Replace with function body.


func _on_Box_Gray_body_entered(body):
	if body.global_position.y < global_position.y && (body.global_position.x < global_position.x || body.global_position.x > global_position.x):
		print("collided from top")
		main.add_child(obj)
		obj.position = position
		
		queue_free()
	pass # Replace with function body.
