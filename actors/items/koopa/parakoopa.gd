extends KinematicBody2D
onready var player = $"/root/Main/Player"
var koopa = preload("koopa_shell.tscn").instance()

func _physics_process(_delta):
	$Sprite.play("flying")

func _on_KoopaCollision_body_entered(_body):
	player.vel.y = -5
	$Kick.play()
	get_parent().add_child(koopa)
	koopa.position = global_position
	$Sprite.visible = false

func _on_Kick_finished():
	queue_free()

func _on_Damage_body_entered(body):
	if body.global_position.x < global_position.x && body.global_position.y > global_position.y:
		print("collided from left")
		player.take_damage_shove(1, -1)
	elif body.global_position.x > global_position.x && body.global_position.y > global_position.y:
		print("collided from right")
		player.take_damage_shove(1, 1)
