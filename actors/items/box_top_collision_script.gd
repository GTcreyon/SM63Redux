extends Area2D

onready var main = $"/root/Main/Items"

var testloaderobj = preload("res://actors/items/fludd.tscn")
var obj = testloaderobj.instance()

func _on_Box_top_entered(body):
	if body.global_position.y < global_position.y && (body.global_position.x < global_position.x || body.global_position.x > global_position.x):
		print("collided from top")
		main.add_child(obj)
		obj.position = get_parent().position
		
		queue_free()
	pass # Replace with function body.
