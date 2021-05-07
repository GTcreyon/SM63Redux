extends Area2D
var enterable = 0

onready var player = $"/root/Main/Player"
export var target_x_pos = 0 
export var target_y_pos = 0 
export var move_to_scene = false
export var next_scene: PackedScene

func _physics_process(delta):
	if enterable == 1 && Input.is_action_just_pressed("up"):
		player.static_v = true
		$DoorSprite.play("opening")
		var t = Timer.new()
		t.set_wait_time(1)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		$DoorSprite.play("closing")
		t.set_wait_time(1)
		t.set_one_shot(true)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		if move_to_scene == true:
			get_tree().change_scene_to(next_scene)
		player.position = Vector2(target_x_pos, target_y_pos) 
		player.static_v = false

func _on_Door_body_entered(body):
	print("in")
	enterable = 1


func _on_Door_body_exited(body):
	print("out")
	enterable = 0
