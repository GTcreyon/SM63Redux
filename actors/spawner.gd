extends Node2D

onready var main = $"/root/Main"
var entity = preload("res://actors/items/coin/coin_yellow.tscn")

export var spawns_per_frame = 0.1
var cycles = 0

func _process(_delta):
	if cycles >= 1 / spawns_per_frame:
		var spawn = entity.instance()
		spawn.position = position
		spawn.dropped = true
		main.add_child(spawn)
		cycles = 0
	cycles += 1
