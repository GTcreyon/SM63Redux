extends KinematicBody2D

const GRAVITY = 0.17
onready var sprite = $AnimatedSprite

var speed = 5
var vel = Vector2.ZERO
var water_bodies : int = 0

export var direction = 1

func _ready():
	sprite.playing = true


func _physics_process(_delta):
	if water_bodies > 0:
		vel.y = min(vel.y + GRAVITY, 2)
	else:
		vel.y = min(vel.y + GRAVITY, 6)
	# warning-ignore:RETURN_VALUE_DISCARDED
	move_and_slide(vel * 60, Vector2.UP)
	vel.x = lerp(vel.x, 0, 0.00625)
	if is_on_floor():
		vel.y = 0
	if is_on_wall(): #flip when hitting wall
		direction *= -1
		vel.x *= -1
	sprite.speed_scale = abs(vel.x)
	if vel.x > 0:
		sprite.animation = "counterclockwise"
	else:
		sprite.animation = "clockwise"


func _on_CollisionArea_body_entered(body):
	if body.hitbox.global_position.y + body.hitbox.shape.extents.y < global_position.y && body.vel.y > 0:
		$Kick.play()
		#print("collided from top")
		$"/root/Main/Player".vel.y = -5
		if body.global_position.x < global_position.x:
			vel.x = speed
		else:
			vel.x = -speed
	elif body.global_position.x < global_position.x:
		#print("collided from left")
		$Kick.play()
		vel.x = speed
	elif body.global_position.x > global_position.x:
		#print("collided from right")
		$Kick.play()
		vel.x = -speed


func _on_WaterCheck_area_entered(area):
	water_bodies += 1


func _on_WaterCheck_area_exited(area):
	water_bodies -= 1
