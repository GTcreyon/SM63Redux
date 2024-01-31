extends Area2D

@onready var collision = $CollisionShape2D
var bodies = []

func snap_bodies():
	if bodies.size() > 0:
		for body in bodies:
			var player_box = body.get_node("Hitbox")
			if (body.vel.y > 0
			and body.position.y + player_box.shape.size.y / 2 + player_box.position.y - 4 < global_position.y + collision.shape.size.y / 2
			):
				body.position.y = global_position.y - collision.shape.size.y / 2 - player_box.shape.size.y / 2 - player_box.position.y
				body.vel.y = 1


func _physics_process(_delta):
	snap_bodies()


func _on_SafetyNet_body_entered(body):
	bodies.append(body)


func _on_SafetyNet_body_exited(body):
	bodies.erase(body)
	if body.vel.y < 0 and (!Input.is_action_pressed("fludd") or Singleton.classic or body.current_nozzle != Singleton.Nozzles.ROCKET):
		body.fludd_power = 100 # air rocket
