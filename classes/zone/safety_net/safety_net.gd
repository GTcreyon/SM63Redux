extends Area2D

onready var collision = $CollisionShape2D
var bodies = []

func snap_bodies():
	if bodies.size() > 0:
		for body in bodies:
			var player_box = body.get_node("Hitbox")
			if (body.vel.y > 0
			and body.position.y + player_box.shape.extents.y + player_box.position.y - 4 < global_position.y + collision.shape.extents.y
			):
				body.position.y = global_position.y - collision.shape.extents.y - player_box.shape.extents.y - player_box.position.y
				body.vel.y = 1


func _physics_process(_delta):
	snap_bodies()


func _on_SafetyNet_body_entered(body):
	bodies.append(body)


func _on_SafetyNet_body_exited(body):
	bodies.erase(body)
	if body.vel.y < 0 and (not Input.is_action_pressed("fludd") or Singleton.classic or Singleton.nozzle != Singleton.n.rocket):
		Singleton.power = 100 # air rocket
