tool
extends StaticBody2D

const texture_dict = {
	"orange":[
		preload("./orange/block_center.png"),
		preload("./orange/block_corner.png"),
		preload("./orange/block_middle.png"),
		preload("./orange/block_side.png"),
		preload("./orange/block_top.png"),
		],
	"white":[
		preload("./white/block_center.png"),
		preload("./white/block_corner.png"),
		preload("./white/block_middle.png"),
		preload("./white/block_side.png"),
		preload("./white/block_top.png"),
		],
}

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


func change_texture(id):
	$Center.texture = texture_dict[id][0]
	$CornerTL.texture = texture_dict[id][1]
	$CornerTR.texture = texture_dict[id][1]
	$CornerBL.texture = texture_dict[id][1]
	$CornerBR.texture = texture_dict[id][1]
	$Middle.texture = texture_dict[id][2]
	$Left.texture = texture_dict[id][3]
	$Right.texture = texture_dict[id][3]
	$Top.texture = texture_dict[id][4]
	$Bottom.texture = texture_dict[id][4]


func set_type(new_type):
	type = new_type
	match type:
		2:
			change_texture("white")
			modulate.a = 0.5
		_:
			change_texture("orange")
			modulate.a = 1

func _ready():
	rotation = angle_offset
	timer = time_offset


func _process(_delta):
	timer += 1
	if timer >= wait:
		turning = true
		timer = 0
	if turning:
		if abs(rad2deg(rotation)) < total_interval + interval:
			rotation += deg2rad(speed)
		else:
			turning = false
			total_interval += interval
			rotation = deg2rad(total_interval) * sign(speed)
