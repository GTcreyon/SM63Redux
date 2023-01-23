class_name LogFall
extends StaticBody2D
# A log that reacts when something stands on it.
# It jitters around, before falling, and disappearing after a set time period.

const GRAVITY = 0.17
const MAX_SPEED = 4
const JITTER = 2

onready var sprite: Sprite = $Sprite
onready var visibility: VisibilityNotifier2D = $VisibilityNotifier2D
onready var ride_area: RideArea = $RideArea

export var disabled: bool = false setget set_disabled
export var wait_time: int = 60
export var lifetime: int = 60

var vel = Vector2.ZERO
var falling: bool = false
var rng = RandomNumberGenerator.new()
var time_falling: int = 0


func _ready():
	rng.seed = hash(position.x + position.y * PI)


func _physics_process(_delta):
	if !disabled:
		if falling:
			if wait_time > 0:
				wait_time -= 1
				# Jitter the sprite around
				sprite.offset = Vector2((rng.randi() % (JITTER + 1)) - JITTER / 2.0, (rng.randi() % (JITTER + 1)) - JITTER / 2.0)
			elif wait_time <= 0:
				# Reset the offset
				sprite.offset = Vector2.ZERO
				
				# Fall until we hit the max speed
				if vel.y <= MAX_SPEED - GRAVITY:
					vel.y += GRAVITY
				else:
					vel.y = MAX_SPEED
				position += vel
			
				time_falling += 1
				
				# If lifetime has expired
				if time_falling > lifetime:
					modulate.a -= 0.125
					
					# Disable collision
					collision_layer = 0
				
				if !visibility.is_on_screen() or modulate.a < 0:
					queue_free()
		else:
			# If something steps on it
			if ride_area.has_rider():
				falling = true
				ride_area.queue_free()


func set_disabled(val):
	disabled = val
	if !is_inside_tree():
		yield(self, "ready")
	set_collision_layer_bit(0, 0 if val else 1)
	ride_area.monitoring = !val
