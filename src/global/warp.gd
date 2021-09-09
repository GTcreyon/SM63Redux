extends Polygon2D

onready var player = $"/root/Main/Player"

var curve = Curve2D.new()
var curve_top = Vector2.ZERO
var curve_arc = Vector2(0, OS.window_size.y / 2)
var curve_bottom = Vector2(0, OS.window_size.y)
var direction = 0
var enter = 0
var set_location = Vector2.ZERO
var scene_path = ""

func _ready():
	curve.add_point(Vector2(0, 0))
	#curve.add_point(Vector2(0, OS.window_size.y / 2))
	curve.add_point(Vector2(0, OS.window_size.y))
	polygon = PoolVector2Array([Vector2(0, 0), Vector2(0, OS.window_size.y / 2), Vector2(0, OS.window_size.y), Vector2(0, OS.window_size.y), Vector2(0, 0)])


func warp(dir, location, path):
	enter = 1
	direction = dir
	set_location = location
	scene_path = path
	var x_pos = (1 - direction.x) * OS.window_size.x / 2
	curve_top = Vector2(x_pos, 0)
	curve_arc = Vector2(0, OS.window_size.y / 2)
	curve_bottom = Vector2(x_pos, OS.window_size.y)


func _process(_delta):
	if enter != 0:
		visible = true
		var speed = OS.window_size.x / 448
		curve_top += 20 * direction * speed
		curve_arc -= 5 * direction * enter * speed
		curve_bottom += 20 * direction * speed
		curve.set_point_position(0, curve_top)
		curve.set_point_out(0, curve_arc)
		curve.set_point_position(1, curve_bottom)
		print(curve_top)
		print(curve_arc)
		print(curve_bottom)
		#print(str(curve.get_point_position(0)) + str(curve.get_point_position(1)) + str(curve.get_point_position(2)))
		if direction.x * enter == -1:
#			print(curve.get_point_position(0))
#			print(curve.get_point_position(1))
			polygon = PoolVector2Array([Vector2(OS.window_size.x, 0)] + Array(curve.get_baked_points()) + [Vector2(OS.window_size.x, OS.window_size.y)])
		else:
			polygon = PoolVector2Array([Vector2(0, 0)] + Array(curve.get_baked_points()) + [Vector2(0, OS.window_size.y)])
		#polygon.append_array(curve.get_baked_points())
		#print(curve.get_baked_points())
		#polygon.append(Vector2(0, 290))
		#print(polygon)
		#draw_polyline(curve.get_baked_points(), Color.red, 2.0)
		#print(curve.get_baked_points())
	if  enter == 1 && ((curve_top.x + curve_arc.x > OS.window_size.x && direction == Vector2.RIGHT) || (curve_top.x + curve_arc.x < 0 && direction == Vector2.LEFT)):
		print("switch")
		#warning-ignore:RETURN_VALUE_DISCARDED
		get_tree().change_scene(scene_path)
		curve.clear_points()
		#curve.add_point(Vector2(OS.window_size.x, 0))
		curve.add_point(Vector2(0, 0))
		#curve.add_point(Vector2(0, OS.window_size.y / 2))
		#curve.add_point(Vector2(OS.window_size.x, OS.window_size.y))
		curve.add_point(Vector2(0, OS.window_size.y))
		var x_pos = (1 - direction.x) * OS.window_size.x / 2
		curve_top = Vector2(x_pos, 0)
		curve_arc = Vector2(0, OS.window_size.y / 2)
		curve_bottom = Vector2(x_pos, OS.window_size.y)
		enter = -1
		#direction = -direction
		$"/root/Main/Player".position = set_location
	elif enter == -1 && ((curve_top.x > OS.window_size.x && direction == Vector2.RIGHT) || (curve_top.x < 0 && direction == Vector2.LEFT)):
		enter = 0
		visible = false
#	if sweep_effect.rect_position.x == 1500:
#		sweep_effect.set_visible(false)
#		turn_on = false
