extends Polygon2D

onready var player = $"/root/Main/Player"

var curve = Curve2D.new()
var curve_top = Vector2.ZERO
var curve_arc = Vector2(0, OS.window_size.y / 2)
var curve_bottom = Vector2(0, OS.window_size.y)
var turn_on = false
var set_location = Vector2.ZERO
var scene_path = ""

func _ready():
	curve.add_point(Vector2(0, 0))
	#curve.add_point(Vector2(0, OS.window_size.y / 2))
	curve.add_point(Vector2(0, OS.window_size.y))
	polygon = PoolVector2Array([Vector2(0, 0), Vector2(0, OS.window_size.y / 2), Vector2(0, OS.window_size.y), Vector2(0, OS.window_size.y), Vector2(0, 0)])
	
func _process(_delta):
	if turn_on == true:
		curve_top += Vector2(20, 0)
		curve_arc -= Vector2(5, 0)
		curve_bottom += Vector2(20, 0)
		curve.set_point_position(0, curve_top)
		curve.set_point_out(0, curve_arc)
		curve.set_point_position(1, curve_bottom)
		#print(str(curve.get_point_position(0)) + str(curve.get_point_position(1)) + str(curve.get_point_position(2)))
		polygon = PoolVector2Array([Vector2(0, 0)] + Array(curve.get_baked_points()) + [Vector2(0, OS.window_size.y)])
		#print(polygon)
		#polygon.append_array(curve.get_baked_points())
		#print(curve.get_baked_points())
		#polygon.append(Vector2(0, 290))
		#print(polygon)
		#draw_polyline(curve.get_baked_points(), Color.red, 2.0)
		#print(curve.get_baked_points())
	if curve_top.x * 3 / 4 > 448 && turn_on:
		get_tree().call_deferred("change_scene", scene_path)
		player.position = set_location
#	if sweep_effect.rect_position.x == 1500:
#		sweep_effect.set_visible(false)
#		turn_on = false
