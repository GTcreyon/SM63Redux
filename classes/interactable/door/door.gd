class_name Door
extends Interactable

export var target_pos: Vector2
export var move_to_scene = false
export var next_scene: PackedScene

var timer = 0
var entered = false
var body_entering = null

func _physics_process(_delta):
	if entered == true:
		timer += 1
	if timer == 60:
		if move_to_scene == true:
			# warning-ignore:return_value_discarded
			get_tree().change_scene_to(next_scene)
		body_entering.position = target_pos
		body_entering.locked = false
		entered = false


func _interact_with(body) -> void:
	body.locked = true
	body_entering = body
	sprite.play("opening")
	entered = true
