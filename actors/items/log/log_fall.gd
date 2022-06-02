extends StaticBody2D

const GRAVITY = 0.17

const JITTER = 2

onready var camera_area = $"/root/Main/CameraArea"
onready var sprite = $Sprite
onready var visibility = $VisibilityNotifier2D

export var wait_time : int = 60

var vel = Vector2.ZERO
var falling : bool = false
var camera_polygon : PoolVector2Array
var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed = hash(position.x + position.y * PI)
	if camera_area != null:
		camera_polygon = Geometry.offset_polygon_2d(camera_area.polygon, 224)[0]

func _physics_process(_delta):
	if falling:
		if wait_time > 0:
			wait_time -= 1
			print(sprite.position)
			sprite.offset = Vector2((rng.randi() % (JITTER + 1)) - JITTER / 2.0, (rng.randi() % (JITTER + 1)) - JITTER / 2.0)
			print(sprite.position)
		elif wait_time <= 0:
			sprite.offset = Vector2.ZERO
			vel.y += GRAVITY
			position += vel
			
		if !visibility.is_on_screen():
			queue_free()

func _on_Area2D_body_entered(_body):
	falling = true
	$Area2D.queue_free()
