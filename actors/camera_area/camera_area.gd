extends Polygon2D

onready var player = $"/root/Main/Player"
onready var camera = player.get_node("Camera2D")

onready var singleton = $"/root/Singleton"
onready var base_modifier: BaseModifier = singleton.base_modifier

onready var collision = $StaticBody2D/CollisionPolygon2D
onready var body = $KinematicBody2D
onready var body_collision = $KinematicBody2D/CollisionShape2D

export var spawn_position: Vector2

func get_rect(poly, margin = 0):
	var min_v = Vector2.INF
	var max_v = -Vector2.INF
	for vec in poly:
		min_v.x = min(min_v.x, vec.x)
		min_v.y = min(min_v.y, vec.y)
		max_v.x = max(max_v.x, vec.x)
		max_v.y = max(max_v.y, vec.y)
	return Rect2(min_v - Vector2(margin, margin), max_v - min_v + Vector2(margin, margin) * 2)

func set_physics_polygon(poly):
	var rect = get_rect(poly, 20)
	var inject = [
		rect.position, rect.position + Vector2(rect.size.x, 0),
		rect.position + rect.size, rect.position + Vector2(0, rect.size.y)
	]
	
	#merge the polygon
	var real = []
	real.append(inject[0])
	real.append_array(poly)
	real.append(poly[0])
	real.append(inject[0])
	inject.invert()
	real.append_array(inject)
	real.remove(real.size() - 1)
	
	polygon = real
	collision.polygon = real

func _ready():
	#invert the current polygon
	set_physics_polygon(polygon)
	
	#create a shape and set it to the correct size
	var shape2d = Shape2D.new()
	body_collision.shape.set_extents(OS.window_size / 2)
	
	body.position = spawn_position
	#make it invisible
	color = Color(0, 0, 0, 0)
	
func _physics_process(dt):
	#handle the scaling of the window / zoom of the camera
	if body_collision.shape:
		var target_size = OS.window_size / 2 * camera.target_zoom
		if target_size != body_collision.shape.get_extents():
			body_collision.shape.set_extents(target_size)
	
	#update the camera position and stuff
	var target = player.position
	body.move_and_slide(((target - body.position) / dt))

	#set the base of the camera to the body
	base_modifier.set_base(camera, "position", body.position - player.position)
