extends KinematicBody2D

onready var player = $"/root/Main/Player"
onready var sprite = $AnimatedSprite
onready var hurtbox = $Damage

var shell = preload("koopa_shell.tscn").instance()
const FLOOR = Vector2(0, -1)
const GRAVITY = 0.17

var vel = Vector2.ZERO
var distance_detector = Vector2()
var speed = 0.9
var init_position = 0
var water_bodies : int = 0

export var mirror = false

func _ready():
	init_position = position
	sprite.frame = hash(position.x + position.y * PI) % 6
	sprite.playing = true


func _physics_process(_delta):
	vel.x = -speed if mirror else speed
	if water_bodies > 0:
		vel.y = min(vel.y + GRAVITY, 2)
	else:
		vel.y = min(vel.y + GRAVITY, 6)
	var snap
	if is_on_floor():
		init_position = position
		vel.y = GRAVITY
		snap = Vector2(0, 4)
	else:
		snap = Vector2.ZERO
	#warning-ignore:RETURN_VALUE_DISCARDED
	move_and_slide_with_snap(vel * 60, snap, Vector2.UP, true)
	#raycast2d is used here to detect if the object collided with a wall
	#to change directions
	if is_on_wall():
		vel.x = 0
		flip_ev()
	
	sprite.flip_h = mirror
	if position.x - init_position.x > 100 or position.x - init_position.x < -100:
		flip_ev()
	
	if hurtbox.monitoring:
		var bodies = hurtbox.get_overlapping_bodies()
		if bodies.size() > 0:
			damage_check(bodies[0])


func flip_ev():
	mirror = !mirror
	$RayCast2D.position.x *= -1


func _on_TopCollision_body_entered(_body):
	if player.position.y < position.y:
		#print("collided from top")
		$Kick.play()
		$"/root/Main/Player".vel.y = -5
		get_parent().call_deferred("add_child", shell)
		shell.position = position + Vector2(0, 7.5)
		$TopCollision.set_deferred("monitoring", false)
		$Damage.monitoring = false
		set_deferred("visible", false)


func _on_Kick_finished():
	queue_free()


func _on_Damage_body_entered(body):
	damage_check(body)
	

func damage_check(body):
	if body.is_spinning():
		$Kick.play()
		get_parent().call_deferred("add_child", shell)
		shell.position = position + Vector2(0, 7.5)
		if body.global_position.x < global_position.x:
			shell.vel.x = 5
		else:
			shell.vel.x = -5
		$TopCollision.set_deferred("monitoring", false)
		$Damage.monitoring = false
		set_deferred("visible", false)
	else:
		if body.global_position.x < global_position.x:
			#print("collided from left")
			body.take_damage_shove(1, -1)
		elif body.global_position.x > global_position.x:
			#print("collided from right")
			body.take_damage_shove(1, 1)


func _on_WaterCheck_area_entered(_area):
	water_bodies += 1


func _on_WaterCheck_area_exited(_area):
	water_bodies -= 1
