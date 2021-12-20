extends Area2D

onready var player = $"/root/Main/Player"
onready var singleton = $"/root/Singleton"
onready var collision = $CollisionShape2D
var has_player = false

func snap_player():
	var player_box = player.get_node("Hitbox")
	if (has_player
	&& player.vel.y > 0
	&& player.position.y + player_box.shape.extents.y + player_box.position.y - 4 < global_position.y + collision.shape.extents.y
	):
		player.position.y = global_position.y - collision.shape.extents.y - player_box.shape.extents.y - player_box.position.y
		player.vel.y = 1
		has_player = false


func _physics_process(_delta):
	snap_player()


func _on_SafetyNet_body_entered(_body):
	has_player = true
	snap_player()


func _on_SafetyNet_body_exited(_body):
	if player.vel.y < 0 && (!Input.is_action_pressed("fludd") || singleton.classic || singleton.nozzle != player.n.rocket):
		singleton.power = 100 #air rocket
	has_player = false
