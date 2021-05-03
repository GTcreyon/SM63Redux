extends KinematicBody2D
onready var lm_counter = $"/root/Main/Player".life_meter_counter
onready var lm_gui = $"/root/Main/Player/Camera2D/GUI/Life_meter_counter"
var shell = preload("koopa_shell.tscn").instance()
const GRAVITY = 10
var speed = 50
const FLOOR = Vector2(0, -1)
var init_position = 0
var velocity = Vector2()
var distance_detector = Vector2()
export var direction = 1
#It's supposed to walk from left to right for some certain distance.
#And then... completely change the scene from Koopa to shell itself when stepped on?
#It doesn't really change from shell to Koopa back, it just permanently stays there.
#Start from zero, whenever it turns back after reaching a certain point, reset and start over again.

func _ready():
	 init_position = position

func _physics_process(_delta):
	velocity.x = speed * direction
	velocity.y += GRAVITY
	velocity = move_and_slide(velocity, FLOOR)
	#raycast2d is used here to detect if the object collided with a wall
	#to change directions
	if is_on_wall():
		flip_ev()
	if direction == 1:
		$Sprite.flip_h = true
	elif direction == -1:
		$Sprite.flip_h = false
	if position.x - init_position.x > 100 or position.x - init_position.x < -100:
		flip_ev()
		
func flip_ev():
	direction *= -1
	$RayCast2D.position.x *= -1


func _on_KoopaCollision_body_entered(body):
	if body.global_position.x < global_position.x && body.global_position.y > global_position.y:
		print("collided from left")
		lm_counter -= 1
		lm_gui.text = str(lm_counter)
		
		$"/root/Main/Player".vel.x = -4
		$"/root/Main/Player".vel.y = -8
	elif body.global_position.x > global_position.x && body.global_position.y > global_position.y:
		print("collided from right")
		lm_counter -= 1
		lm_gui.text = str(lm_counter)
		
		$"/root/Main/Player".vel.x = 4
		$"/root/Main/Player".vel.y = -8
	if body.global_position.y < global_position.y && (body.global_position.x < global_position.x || body.global_position.x > global_position.x):
		print("collided from top")
		get_parent().add_child(shell)
		shell.position = position
		queue_free()
