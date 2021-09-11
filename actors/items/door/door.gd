extends Area2D
var enterable = 0

onready var player = $"/root/Main/Player"
export var target_x_pos = 0 
export var target_y_pos = 0 
export var move_to_scene = false
export var next_scene: PackedScene
var timer = 0
var entered = false
func _physics_process(delta):
	if enterable == 1 && Input.is_action_just_pressed("up"):
		player.static_v = true
		$DoorSprite.play("opening")
		entered = true
	if entered == true:
		timer += 1
	if timer == 60:
		if move_to_scene == true:
			get_tree().change_scene_to(next_scene)
		player.position = Vector2(target_x_pos, target_y_pos) 
		player.static_v = false
		entered = false
func _on_Door_body_entered(body):
	#print("in")
	enterable = 1
func _on_Door_body_exited(body):
	#print("out")
	enterable = 0
