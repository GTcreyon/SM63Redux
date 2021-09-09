extends KinematicBody2D
onready var lm_counter = $"/root/Main/Player".life_meter_counter
onready var player = $"/root/Main/Player"
onready var lm_gui = $"/root/Main/Player/Camera2D/GUI/Life_meter_counter"
var koopa = preload("koopa_shell.tscn").instance()

func _physics_process(delta):
	$Sprite.play("flying")

func _on_KoopaCollision_body_entered(body):
	player.vel.y = -5
	$Kick.play()
	get_parent().add_child(koopa)
	koopa.position = global_position
	$Sprite.visible = false
	$Damage/Collision.queue_free()

func _on_Kick_finished():
	queue_free()

func _on_Damage_body_entered(body):
	player.life_meter_counter -= 1
