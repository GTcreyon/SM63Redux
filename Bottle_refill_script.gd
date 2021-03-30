extends Area2D

export var bottle_type = 1

var increment = 0

onready var player = get_node("../../Player")

func _on_Bottle_small_body_entered(_body):
	if bottle_type == 1:
		increment = 10
	elif bottle_type == 2:
		increment = 20
		
	player.water = min(player.water + increment, 100)
	queue_free()
