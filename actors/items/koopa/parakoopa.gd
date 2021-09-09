extends KinematicBody2D
onready var lm_counter = $"/root/Main/Player".life_meter_counter
onready var lm_gui = $"/root/Main/Player/Camera2D/GUI/Life_meter_counter"
var shell = preload("koopa_shell.tscn").instance()
var parakoopa_pos = Vector2(global_position)

func _physics_process(delta):
	$Sprite.play("flying")


func _on_KoopaCollision_body_entered(body):
	get_parent().add_child(shell)
	shell.set_position(parakoopa_pos)
	queue_free()
