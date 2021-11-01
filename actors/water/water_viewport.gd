extends Sprite

onready var viewport: Viewport = $Viewport
onready var water: Polygon2D = $Viewport/WaterPolygon
onready var detection_area: Area2D = $DetectionArea
onready var collision: CollisionPolygon2D = $DetectionArea/Collision

export var polygon: PoolVector2Array = PoolVector2Array()

func refresh():
	viewport.world_2d = get_world_2d()
	#get the extends
	var min_vec = Vector2.INF
	var max_vec = -Vector2.INF
	for poly in polygon:
		min_vec.x = min(min_vec.x, poly.x)
		min_vec.y = min(min_vec.y, poly.y)
		max_vec.x = max(max_vec.x, poly.x)
		max_vec.y = max(max_vec.y, poly.y)
	if min_vec == Vector2.INF: #if we have 0 polygons, then don't do anything
		return
	#set the size to the extends of the polygon
	var size_extends = max_vec - min_vec
	var size_diff = Vector2(64, 64)
	viewport.size = size_extends + size_diff
	#set the water polygon and start it
	water.position += size_diff / 2
	water.polygon = polygon
	#now set the collision polygon
	collision.polygon = PoolVector2Array([
		Vector2(0, 0), Vector2(size_extends.x, 0),
		size_extends, Vector2(0, size_extends.y)
	])
	#handle position stuff
	position += size_extends / 2
	collision.position -= size_extends / 2
	detection_area.top_left_corner = position - size_extends / 2
	#start!
	detection_area.on_ready()
	
	#shader copy time
	var tex = ImageTexture.new()
	tex.create(viewport.size.x, viewport.size.y, Image.FORMAT_RGB8)
	texture = tex
	#now give the shader our viewport texture
	material.set_shader_param("viewport_texture", viewport.get_texture())

func _ready():
	refresh()
