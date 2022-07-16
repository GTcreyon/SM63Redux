tool
extends StaticBody2D

const texture_list = [
	[preload("./block_normal_fill.png"), preload("./block_normal_case.png"),],
	[preload("./block_ghost_fill.png"), preload("./block_ghost_case.png"),],
]

onready var ride_area = $RideArea

export var size = Vector2(64, 64) setget set_size
export var speed = 1
export var wait = 120
export var time_offset = 0
export var interval = 90
export var angle_offset = 0
export var type = 1 setget set_type

var timer = 0
var turning = false
var total_interval = 0

func set_size(new_size):
	size = new_size
	$Middle.rect_size = size - (Vector2.ONE * 8)
	$Middle.rect_position = (Vector2.ONE * 8 - size) / 2
	$Top.rect_size = Vector2(size.x - 8, 4)
	$Top.rect_position = Vector2(8 - size.x, -size.y) / 2
	$Bottom.rect_size = Vector2(size.x - 8, 4)
	$Bottom.rect_position = Vector2(8 - size.x, size.y - 8) / 2
	$Left.rect_size = Vector2(4, size.y - 8)
	$Left.rect_position = Vector2(-size.x, 8 - size.y) / 2
	$Right.rect_size = Vector2(4, size.y - 8)
	$Right.rect_position = Vector2(size.x - 8, 8 - size.y) / 2
	$CornerTL.position = Vector2(4 - size.x, 4 - size.y) / 2
	$CornerTR.position = Vector2(size.x - 4, 4 - size.y) / 2
	$CornerBL.position = Vector2(4 - size.x, size.y - 4) / 2
	$CornerBR.position = Vector2(size.x - 4, size.y - 4) / 2
	$Collision.shape.extents = size / 2
	$RideArea/RideShape.shape.extents = size / 2 + Vector2.ONE * 2


func change_texture(id):
	var tex = texture_list[id]
	$Middle.texture = tex[0]
	$Center.texture.atlas = tex[1]
	$CornerTL.texture.atlas = tex[1] #most textures are just references to others
	$Left.texture.atlas = tex[1]
	$Top.texture.atlas = tex[1]


func set_type(new_type):
	type = new_type
	change_texture(new_type - 1)
	match type:
		2:
			modulate.a = 0.5
		_:
			modulate.a = 1

func _ready():
	rotation = angle_offset
	timer = time_offset


func _physics_process(_delta):
	timer += 1
	if timer >= wait:
		turning = true
		timer = 0
	if turning && !Engine.editor_hint:
		if abs(rad2deg(rotation)) < total_interval + interval:
			rotation += deg2rad(speed)
		else:
			turning = false
			total_interval += interval
			rotation = deg2rad(total_interval) * sign(speed)
		for body in ride_area.get_overlapping_bodies():
			if body.is_on_floor():
				var vec = position - body.position
				var dist = position.distance_to(body.position)
				var rot = atan2(vec.y, vec.x);
				var diff = Vector2(cos(rot) * dist - cos(rot + deg2rad(speed)) * dist, sin(rot) * dist - sin(rot + deg2rad(speed)) * dist)
				body.position += diff
