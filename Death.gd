extends Node2D

onready var player = $"/root/Main/Player"

func _ready():
	pass
		
func deathanim():
	$DeathAnim.play("Death")
