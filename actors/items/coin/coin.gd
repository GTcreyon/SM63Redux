extends KinematicBody2D

onready var singleton = $"/root/Singleton"
var dropped = false
var vel = Vector2(0.0, 0.0)

func _ready():
	vel.x = (singleton.rng.randf() * 4 - 2) * 0.53
	vel.y = -7 * 0.53


func _physics_process(_delta):
	if dropped:
		vel.y += 0.2
		if vel.y > 0:
			vel.y *= 0.98
		if is_on_floor():
			vel.y = -vel.y / 2
			if abs(vel.y) < 0:
				vel.y = 0
		
		if is_on_wall():
			vel.x = -vel.x / 2
		# warning-ignore:RETURN_VALUE_DISCARDED
		move_and_slide(vel * 60, Vector2.UP)


func _on_SFX_finished():
	queue_free()
