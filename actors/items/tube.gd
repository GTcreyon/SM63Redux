extends StaticBody2D

onready var player = $"/root/Main/Player"
var can_warp = false

export var target_x_pos = 0
export var target_y_pos = 0

func _process(_delta):
	if can_warp && Input.is_action_pressed("down"):
		can_warp = false
		player.position = Vector2(target_x_pos, target_y_pos)

func _on_mario_top(body):
	if body.global_position.y < global_position.y:
		print("on top")
		can_warp = true

func _on_mario_off(body):
		print("not on top")
		can_warp = false
