extends KinematicBody2D

const GRAVITY = 0.17

const JITTER = 2

onready var camera_area = $"/root/Main/CameraArea"
onready var sprite = $Sprite

var vel = Vector2.ZERO
var fall_timer : int = -1
var camera_polygon : PoolVector2Array
var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed = hash(position.x + position.y * PI)
	if camera_area != null:
		camera_polygon = Geometry.offset_polygon_2d(camera_area.polygon, 224)[0]

func _process(delta):
	if fall_timer > 0:
		fall_timer -= 1
		sprite.position = Vector2((rng.randi() % JITTER) - JITTER / 2.0, (rng.randi() % JITTER) - JITTER / 2.0)
	elif fall_timer == 0:
		sprite.position = Vector2.ZERO
		vel.y += GRAVITY
		move_and_slide(vel * 60)
	if !Geometry.is_point_in_polygon(position, camera_polygon):
		queue_free()

func _on_Area2D_body_entered(_body):
	fall_timer = 60
	$Area2D.queue_free()
