@tool
class_name TippingLog
extends Telescoping

@onready var rod = $Rod
@onready var ride_area = $Rod/RideArea

@export var pivot_offset = 0: set = set_pivot_offset

var ang_vel = 0


func set_width(val):
	super.set_width(val)
	# warning-ignore:integer_division
	$Rod/RideArea/RideShape.shape.size.x = middle_segment_width / 2 * val + end_segment_width


func _physics_process(_delta):
	if !Engine.is_editor_hint() and !disabled:
		physics_step()


func physics_step():
	# Calculate total torque
	# M = Fd
	# F will just be a constant for now
	# TODO: Consider using fall speed as F
	
	var riders = ride_area.get_riding_bodies()
	for body in riders:
		var angle = get_angle_to(body.position)
		var dist = position.distance_to(body.position)
		var perpendicular_dist = cos(angle) * dist # Calculate perpendicular distance from pivot
		ang_vel += perpendicular_dist / 8000 / width
	
	rotation += ang_vel
	if rotation > deg_to_rad(1):
		ang_vel -= deg_to_rad(0.025)
	elif rotation < deg_to_rad(-1):
		ang_vel += deg_to_rad(0.025)
	rotation = lerp(rotation, 0, 0.0125)
	ang_vel = lerp(ang_vel, 0, 0.0125)
	for body in riders:
		var dist = position.distance_to(body.position)
		# warning-ignore:return_value_discarded
		body.set_velocity(Vector2(rotation_degrees * 0.076 * 32, sin(ang_vel) * dist * 32))
		body.floor_snap_length = 4
		body.set_up_direction(Vector2.UP)
		body.set_floor_stop_on_slope_enabled(true)
		body.move_and_slide()
		body.velocity


func set_disabled(val):
	disabled = val
	if rod == null:
		rod = $Rod
	if ride_area == null:
		ride_area = $Rod/RideArea
	rod.set_collision_layer_value(0, 0 if val else 1)
	ride_area.monitoring = !val


func set_pivot_offset(val):
	pivot_offset = val
	if rod == null:
		rod = $Rod
	rod.position.x = -val
