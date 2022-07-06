tool
extends KinematicBody2D

onready var sprite = $AnimatedSprite
onready var hurtbox = $Damage
onready var top_collision = $TopCollision
onready var raycast = $RayCast2D
onready var raycastcenter = $CenterRayCast2D

var shell = preload("koopa_shell.tscn").instance()
const FLOOR = Vector2(0, -1)
const GRAVITY = 0.17

var vel = Vector2.ZERO
var distance_detector = Vector2()
var speed = 0.9
var init_position = 0
var water_bodies : int = 0

const color_presets = [
	[ # green
		Color("9cc56d"),
		Color("1f887a"),
		Color("2b4a3d"),
	],
	[ # red
		Color("CB5E09"),
		Color("911230"),
		Color("7A4234"),
	],
]

export var disabled = false setget set_disabled
export var mirror = false
export(int, "green", "red") var color = 0 setget set_color

func set_color(new_color):
	for i in range(3):
		material.set_shader_param("color" + str(i), color_presets[new_color][i])
	color = new_color

func _ready():
	if !Engine.editor_hint:
		init_position = position
		sprite.frame = hash(position.x + position.y * PI) % 6
		sprite.playing = !disabled
		if mirror: raycast.position.x *= -1
	
	# 'local to scene' doesn't work if the instance is duplicated with ctrl+d
	# so this protects against ents sharing materials and therefore visual colors
	material = material.duplicate()

func _physics_process(_delta):
	if !disabled and !Engine.editor_hint:
		physics_step()


func physics_step():
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
	
	if is_on_wall() or is_on_floor() and color == 1 and !raycast.is_colliding():
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
	raycast.position.x *= -1


func _on_TopCollision_body_entered(body):
	if body.position.y < position.y:
		#print("collided from top")
		$Kick.play()
		body.vel.y = -5
		get_parent().call_deferred("add_child", shell)
		shell.position = position + Vector2(0, 7.5)
		shell.color = color
		top_collision.set_deferred("monitoring", false)
		hurtbox.monitoring = false
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
		top_collision.set_deferred("monitoring", false)
		hurtbox.monitoring = false
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


func set_disabled(val):
	disabled = val
	if hurtbox == null:
		hurtbox = $Damage
	if top_collision == null:
		top_collision = $TopCollision
	if raycast == null:
		raycast = $RayCast2D
	if sprite == null:
		sprite = $AnimatedSprite
	hurtbox.monitoring = !val
	top_collision.monitoring = !val
	raycast.enabled = !val
	
	if !Engine.editor_hint:
		sprite.playing = !val
