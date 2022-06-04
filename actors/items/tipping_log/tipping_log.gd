tool
extends Sprite

const MIDDLE_WIDTH = 32
const EDGE_WIDTH = 3

onready var rod = $Rod
onready var ride_area = $Rod/RideArea

export var disabled = false setget set_disabled
export var pivot_offset = 0 setget set_pivot_offset
export(int, 1, 100) var length = 1 setget set_length

var ang_vel = 0

func set_length(val):
	length = val
	$Rod/Middle.visible = true
	$Rod/Collision.disabled = false
	$Rod/Middle.rect_size.x = MIDDLE_WIDTH * val
	$Rod/Middle.rect_position.x = -MIDDLE_WIDTH / 2 * val
	$Rod/Collision.shape.extents.x = MIDDLE_WIDTH / 2 * val + EDGE_WIDTH
	$Rod/RideArea/RideShape.shape.extents.x = MIDDLE_WIDTH / 2 * val + EDGE_WIDTH
	$Rod/Left.position.x = -MIDDLE_WIDTH / 2 * val
	$Rod/Right.position.x = MIDDLE_WIDTH / 2 * val


func _physics_process(_delta):
	if !Engine.editor_hint && !disabled:
		physics_step()


func physics_step():
	# calculate total torque
	# M = Fd
	# yeah i know this is the formula for moments shush
	# F will just be a constant for now
	# maybe objects could have weights at some point idk
	
	var riders = []
	for body in ride_area.get_overlapping_bodies():
		if body.is_on_floor():
			riders.append(body)
	
	var pivot_pos = Vector2(position.x + cos(rotation) * pivot_offset, position.y + sin(rotation) * pivot_offset)
	for body in riders:
		var angle = get_angle_to(body.position)
		var dist = position.distance_to(body.position)
		var perpendicular_dist = cos(angle) * dist #calculate perpendicular distance from pivot
		ang_vel += perpendicular_dist / 8000 / length
	
	rotation += ang_vel
	if rotation > deg2rad(1):
		ang_vel -= deg2rad(0.025)
	elif rotation < deg2rad(-1):
		ang_vel += deg2rad(0.025)
	rotation = lerp(rotation, 0, 0.0125)
	ang_vel = lerp(ang_vel, 0, 0.0125)
	for body in riders:
		var dist = position.distance_to(body.position)
		#warning-ignore:return_value_discarded
		body.move_and_slide_with_snap(Vector2(rotation_degrees * 0.076 * 32, sin(ang_vel) * dist * 32), Vector2(0, 4), Vector2.UP, true)


func set_disabled(val):
	disabled = val
	if rod == null:
		rod = $Rod
	if ride_area == null:
		ride_area = $Rod/RideArea
	rod.set_collision_layer_bit(0, 0 if val else 1)
	ride_area.monitoring = !val


func set_pivot_offset(val):
	pivot_offset = val
	if rod == null:
		rod = $Rod
	rod.position.x = -val
