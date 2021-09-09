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
	$Damage/Collision.queue_free()

func _on_Kick_finished():
	queue_free()

func _on_Damage_body_entered(_body):
	player.life_meter_counter -= 1
