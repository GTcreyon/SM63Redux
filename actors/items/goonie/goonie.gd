extends StaticBody2D

var rng = RandomNumberGenerator.new()
var time_count = 0
var vel = Vector2.ZERO
var riding = 0
var block_riders = []
var reset_position = position
var reset_timer = 90
var camera_polygon

onready var camera_area = $"/root/Main/CameraArea"
onready var sprite = $AnimatedSprite
onready var ride_area = $RideArea

const up_time = 250.0*60/32 #maximum time a bird will flap up
const down_time = 45.0*60/32 #maximum time a bird will swoop down

func _ready():
	if camera_area != null:
		camera_polygon = Geometry.offset_polygon_2d(camera_area.polygon, 224)[0]
		var points = camera_polygon.size()
		for i in range(points):
			var from : Vector2 = camera_polygon[i]
			var to : Vector2 = camera_polygon[(i + 1) % points]
			var intersect = Geometry.segment_intersects_segment_2d(from, to, position, Vector2(-99999, 0))
			if intersect != null:
				reset_position = intersect + Vector2.LEFT * 20
	rng.seed = hash(position.x + position.y * PI) #each bird will be different, but behave the same way each time
	sprite.frame = rng.seed % 7
	sprite.playing = true
	
	time_count = rng.randi_range(0, up_time/2)
	vel.x = 2 + rng.randf() * 0.5
	if sprite.flip_h:
		vel.x *= -1
	vel.y = -0.7 - rng.randf() * 0.25


func _physics_process(_delta):
	var move_vec = Vector2.ZERO
	
	for body in block_riders:
		if body.vel.y > 0:
			riding += 1
			block_riders.erase(body)
	
	if riding > 0:
		move_vec = Vector2(vel.x*32/60, 0.36)
		position += move_vec
		for body in ride_area.get_overlapping_bodies():
			if body.is_on_floor():
				body.move_and_collide(move_vec)
	else:
		if sprite.animation == "flap":
			move_vec = Vector2(vel.x*32/60, vel.y*32/60)
			position += move_vec
			if time_count >= up_time && sprite.frame == 2:
				sprite.animation = "swoop"
				
				time_count = rng.randi_range(0, down_time/2)
		else:
			move_vec = Vector2(vel.x * 1.5*32/60, 1.5*32/60)
			position += move_vec
			if time_count >= down_time:
				sprite.animation = "flap"
				sprite.frame = 5
				time_count = rng.randi_range(0, up_time/2)
	
	if riding <= 0:
		time_count += 1
	
	if camera_area != null:
		if Geometry.is_point_in_polygon(position, camera_polygon):
			reset_timer = 90
		else:
			reset_timer -= 1
			if reset_timer <= 0:
				position = reset_position
				reset_timer = 90


func _on_RideArea_body_entered(body):
	if body.vel.y > 0:
		sprite.animation = "flap"
		sprite.speed_scale = 3
		riding += 1
	else:
		block_riders.append(body)


func _on_RideArea_body_exited(body):
	if block_riders.has(body):
		block_riders.erase(body)
	else:
		riding -= 1
		if riding <= 0:
			sprite.speed_scale = 1
