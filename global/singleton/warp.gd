class_name Warp
extends Polygon2D

var curve = Curve2D.new()
var curve_top = Vector2.ZERO
var direction = 0
var enter = 0
var set_location = null
var scene_path = ""
var flip = false
var anim_timer = 0

@onready var window = get_window()
@onready var curve_arc = Vector2(0, float(window.size.y) / 2)
@onready var curve_bottom = Vector2(0, window.size.y)

func _ready():
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0, window.size.y))
	polygon = PackedVector2Array([
		Vector2(0, 0),
		Vector2(0, float(window.size.y) / 2),
		Vector2(0, window.size.y),
		Vector2(0, window.size.y),
		Vector2(0, 0)
	])


func warp(dir: Vector2, location: Vector2, path: String):
	# Preconvert this to a float vector to avoid int-division errors.
	var window_size = Vector2(window.size)
	
	var cam_area = $"/root/Main/CameraArea"
	if cam_area != null:
		cam_area.frozen = true
	enter = 1
	direction = dir
	Singleton.warp_location = location
	scene_path = path
	
	var pos
	if direction.y == 0:
		pos = (1 - direction.x) * window_size.x / 2
		curve_top = Vector2(pos, 0)
		curve_arc = Vector2(0, window_size.y / 2)
		curve_bottom = Vector2(pos, window_size.y)
	else:
		pos = (1 - direction.y) * window_size.y / 2
		curve_top = Vector2(0, pos)
		curve_arc = Vector2(window_size.x / 2, 0)
		curve_bottom = Vector2(window_size.x, pos)


func _physics_process(_delta):
	if enter != 0:
		anim_timer += 1
	if (enter == 1 and anim_timer >= 44):
		# Preconvert this to a float vector to avoid int-division errors.
		var window_size = Vector2(window.size)
		
		anim_timer = 0
		
		curve.clear_points()
		curve.add_point(Vector2(0, 0))
		var pos
		if direction.x == 0:
			curve.add_point(Vector2(0, window_size.y))
			pos = (1 - direction.y) * window_size.y / 2
			curve_top = Vector2(0, pos)
			curve_arc = Vector2(window_size.x / 2, 0)
			curve_bottom = Vector2(window_size.x, pos)
		else:
			curve.add_point(Vector2(window_size.x, 0))
			pos = (1 - direction.x) * window_size.x / 2
			curve_top = Vector2(pos, 0)
			curve_arc = Vector2(0, window_size.y / 2)
			curve_bottom = Vector2(pos, window_size.y)
		
		Singleton.warp_to(scene_path, $"/root/Main/Player")
		
		enter = -1
	elif enter == -1 and anim_timer >= 44:
		anim_timer = 0
		enter = 0
		visible = false


func _process(delta):
	var dmod = min(60 * delta, 1)
	if enter != 0:
		# Preconvert this to a float vector to avoid int-division errors.
		var window_size = Vector2(window.size)
		
		visible = true
		var speed
		if direction.x == 0:
			speed = window_size.y / Singleton.DEFAULT_SIZE.y
		else:
			speed = window_size.x / Singleton.DEFAULT_SIZE.x
		curve_top += 20 * direction * speed * dmod
		curve_arc -= 5 * direction * enter * speed * dmod
		curve_bottom += 20 * direction * speed * dmod
		curve.set_point_position(0, curve_top)
		curve.set_point_out(0, curve_arc)
		curve.set_point_position(1, curve_bottom)
		if direction.x == 0:
			if direction.y * enter == -1:
				polygon = PackedVector2Array([Vector2(0, window_size.y)] + Array(curve.get_baked_points()) + [Vector2(window_size.x, window_size.y)])
			else:
				polygon = PackedVector2Array([Vector2(0, 0)] + Array(curve.get_baked_points()) + [Vector2(window_size.x, 0)])
		else:
			if direction.x * enter == -1:
				polygon = PackedVector2Array([Vector2(window_size.x, 0)] + Array(curve.get_baked_points()) + [Vector2(window_size.x, window_size.y)])
			else:
				polygon = PackedVector2Array([Vector2(0, 0)] + Array(curve.get_baked_points()) + [Vector2(0, window_size.y)])
