extends KinematicBody2D

var follow = false
var move = Vector2.ZERO
export var speed = 1
var direction = null
onready var player = $"/root/Main/Player"
onready var sprite = $Sprite

func _physics_process(_delta):
	move = Vector2.ZERO
	
	if follow:
		direction = player.position - position
		move = position.direction_to(player.position) * speed
		rotation = direction.angle()
		if rotation >= 270:
			sprite.flip_v = true
	else:
		move = Vector2.ZERO
	
		
	move = move.normalized()
	move = move_and_collide(move)
	

func _on_Following_body_entered(_body):
	follow = true


func _on_Following_body_exited(_body):
	follow = false


func _on_Damage_body_entered(body):
	if body.global_position.x < global_position.x && body.global_position.y > global_position.y:
		#print("collided from left")
		player.take_damage_shove(1, -1)
	elif body.global_position.x > global_position.x && body.global_position.y > global_position.y:
		#print("collided from right")
		player.take_damage_shove(1, 1)
