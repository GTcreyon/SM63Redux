class_name LogFall
extends StaticBody2D

const GRAVITY = 0.17

const JITTER = 2

onready var sprite: Sprite = $Sprite
onready var visibility: VisibilityNotifier2D = $VisibilityNotifier2D
onready var ride_area: RideArea = $RideArea

export var disabled: bool = false setget set_disabled
export var wait_time: int = 60

var vel = Vector2.ZERO
var falling: bool = false
var rng = RandomNumberGenerator.new()


func _ready():
	rng.seed = hash(position.x + position.y * PI)


func _physics_process(_delta):
	if falling:
		if !disabled:
			if wait_time > 0:
				wait_time -= 1
				sprite.offset = Vector2((rng.randi() % (JITTER + 1)) - JITTER / 2.0, (rng.randi() % (JITTER + 1)) - JITTER / 2.0)
			elif wait_time <= 0:
				sprite.offset = Vector2.ZERO
				vel.y += GRAVITY
				position += vel
				
			if !visibility.is_on_screen():
				queue_free()
	else:
		if ride_area.has_rider():
			falling = true
			ride_area.queue_free()


func set_disabled(val):
	disabled = val
	if !is_inside_tree():
		yield(self, "ready")
	set_collision_layer_bit(0, 0 if val else 1)
	ride_area.monitoring = !val
