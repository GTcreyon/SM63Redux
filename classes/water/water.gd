extends Area2D

const SPLASH_BANK = {
	"big": [
		preload("res://classes/water/splash_big_0.wav"),
		preload("res://classes/water/splash_big_1.wav"),
	],
	"medium": [
		preload("res://classes/water/splash_medium_0.wav"),
		preload("res://classes/water/splash_medium_1.wav"),
	],
	"small": [
		preload("res://classes/water/splash_small_0.wav"),
		preload("res://classes/water/splash_small_1.wav"),
	],
}
const WAVE_MIN_SIZE = 2

@export var water_segment_size = 20 # In pixels, this works regardless of water scale.
@export var surface_wave_properties = {
	width = 32, # In pixels
	height = 4, # In pixels
	speed = 1 # Idk it just works
}
@export var top_left_corner = Vector2() # Gets automatically set by the parent script

var waves = []
var surface = {}
var surface_width_keys = 0
var elapsed_time = 0
var wave_id_counter = 0

@onready var render_polygon: Polygon2D = $"../SubViewport/WaterPolygon"
@onready var player = $"/root/Main/Player"
@onready var camera = $"/root/Main/Player/Camera"
@onready var splash = $"../Splash"


# Update the shader with the latest information
func _process(dt):
	elapsed_time += dt
	
	# Dictionary of all waves' effects on all verts.
	# TODO: These effects will all just be summed in the end.
	# We could just add them together as they're calculated.
	var wave_y_modifier = {}

	for wave in waves:
		# First, decay the wave's size.
		wave.height -= wave.reduce * dt
		wave.width -= wave.reduce_width * dt
		# If our wave has become incredibly small, remove it.
		if wave.height <= WAVE_MIN_SIZE or wave.width <= WAVE_MIN_SIZE:
			waves.erase(wave)
			
			# Do not skip the rest of the code.
			# Set the wave height to 0 and it will clear itself up.
			wave.height = 0
		
		# Advance the wave along the surface.
		wave.current_position.x += wave.speed * wave.direction * dt
		# TODO: speed is directionful, which means there's two direction
		# properties. Confusing!
		wave.travelled_distance += abs(wave.speed * wave.direction * dt)
		
		# Update the current and next vertex position,
		# also flip the direction if needed
		if (
			wave.speed * wave.direction >= 0
			and
			wave.current_position.x >= surface[wave.next_vert].x
		) or (
			wave.speed * wave.direction <= 0
			and wave.current_position.x <= surface[wave.next_vert].x
		):
			wave.cur_vert = wave.next_vert
			wave.next_vert = _next_vertex_key(wave)
			wave.speed *= (1 if wave.next_vert >= wave.cur_vert else -1) \
				* sign(wave.speed * wave.direction)
		
		# Find the min/max indices of this surface.
		# Find width of wave in verts.
		var ind_width = wave.width / water_segment_size
		# Initial guess based solely on wave size.
		var min_ind = round(wave.cur_vert - ind_width / 2)
		var max_ind = round(wave.cur_vert + ind_width / 2)
		# Iterate backwards to validate the guessed minimum...
		for ind in range(wave.cur_vert, min_ind - 1, -1):
			if not surface.has(ind):
				min_ind = ind + 1
				break
		# ...then forwards to validate the maximum.
		for ind in range(wave.cur_vert, max_ind):
			if not surface.has(ind):
				max_ind = ind - 1
				break
		
		# Get the width of this surface in vertices.
		ind_width = max_ind - min_ind
		# Generate a hill effect for this wave using sine
		var vert_phase = 0
		for ind in range(min_ind, max_ind):
			# TODO: Could calc vert phase here:
			# vert_phase = float(ind - min_ind) / float(ind_width)
			
			# Calc sine for this vertex, scaled by wave params.
			var y_mod = -sin(float(vert_phase) / float(ind_width) * PI)
			y_mod *= wave.height * wave.height_direction
			# Update phase for the next vert.
			vert_phase += 1
			
			# Save Y mod calculated for this wave and this vertex.
			# Init the dictionary for this vert if it hasn't been hit before.
			if wave_y_modifier.has(ind):
				wave_y_modifier[ind][wave.id] = y_mod
			else:
				wave_y_modifier[ind] = {[wave.id]: y_mod}

	# Apply default "still water" ripple.
	var x_os_size = get_window().size.x
	var x_camera_edge = camera.global_position.x - x_os_size / 2
	for key in surface.keys():
		var global_x = surface[key].x + top_left_corner.x
		if global_x >= x_camera_edge + x_os_size:
			break
		if global_x >= x_camera_edge:
			surface[key].y = sin(
				global_x * PI / surface_wave_properties.width
				+ elapsed_time * 2 * PI * surface_wave_properties.speed
			) * surface_wave_properties.height
	
	# Apply the calculated modifier values.
	for surf_key in wave_y_modifier.keys():
		for add_y in wave_y_modifier[surf_key].values():
			surface[surf_key].y += add_y

	# Now actually set the verts
	_set_surface_verts(surface)


func _on_body_entered(body):
	_handle_impact(body, false)


func _on_body_exited(body):
	_handle_impact(body, true)
	# If player jumped out of water, cue them to switch to walk state.
	if body == player and get_overlapping_bodies().count(player) == 1:
		player.call_deferred("switch_state", player.s.walk)


func on_ready():
	_subdivide_surface()


# Subdivide the water surface
func _subdivide_surface():
	# The approach we take here is to recreate the polygon from scratch,
	# adding chains of verts where the surface is exactly flat.
	# This array will contain the recreated (subdivided) polygon.
	var verts = PackedVector2Array()
	# We also want to access the size of the source polygon often.
	var size = render_polygon.polygon.size()
	
	for i in range(0, size):
		# Direction to next vert.
		# TODO: Direction is a tad slow to calculate. Since we only care if the
		# segment is exactly flat, we could just compare the verts' Y values.
		var dir = render_polygon.polygon[i].direction_to(render_polygon.polygon[(i+1) % size])
		
		# Start adding verts if the surface is exactly flat.
		if dir == Vector2.RIGHT:
			var start = render_polygon.polygon[i]
			# Add a row of regularly spaced verts as long as the segment.
			while start.x < render_polygon.polygon[(i+1) % size].x:
				verts.append(start)
				start += dir * water_segment_size
			# If the row ended up shorter than the source, add the endpoint.
			if !verts[verts.size() - 1].is_equal_approx(render_polygon.polygon[(i+1) % size]):
				verts.append(render_polygon.polygon[(i+1) % size])
		# If the surface isn't flat, just copy from the source polygon.
		else:
			verts.append(render_polygon.polygon[i])
	
	# Give the new verts to the polygon.
	_set_polygon_verts(verts)
	# Update the surface data fron the new polygon as well.
	surface = _get_surface_verts()
	surface_width_keys = len(surface) - 1


func _set_polygon_verts(verts: PackedVector2Array):
	render_polygon.polygon = verts


func _get_surface_verts():
	var vertices = {}
	var size = render_polygon.polygon.size()
	for i in size:
		# If this vert is part of a flat surface, save it to the dictionary.
		if render_polygon.polygon[i].direction_to(render_polygon.polygon[(i + 1) % size]) == Vector2.RIGHT\
			or render_polygon.polygon[((i - 1) + size) % size].direction_to(render_polygon.polygon[i]) == Vector2.RIGHT:
			vertices[i] = render_polygon.polygon[i]
	return vertices


func _set_surface_verts(dict):
	var copy = PackedVector2Array(render_polygon.polygon)
	for k in dict.keys():
		copy.set(k, dict[k])
	_set_polygon_verts(copy)


func _next_vertex_key(wave: Dictionary) -> int:
	var check_direction: int = (1 if wave.speed >= 0 else -1) * wave.direction
	if surface.has(wave.cur_vert + check_direction):
		return wave.cur_vert + check_direction
	elif surface.has(wave.cur_vert - check_direction):
		return wave.cur_vert - check_direction
	else:
		return wave.cur_vert


func _nearest_vertex_key(pos: Vector2) -> int:
	var key
	var nearest_dist = INF
	# Iterate every vert, comparing distances.
	# Save the one that's closest to the requested position.
	# TODO: Binary search? Would that speed things up??
	for vertKey in surface.keys():
		var dist = (surface[vertKey] - pos).length()
		if dist < nearest_dist:
			key = vertKey
			nearest_dist = dist
	return key


func _move_wave(wave, new):
	wave.current_position = new
	wave.cur_vert = _nearest_vertex_key(new)
	wave.next_vert = _next_vertex_key(wave)
	wave.speed = wave.speed * (1 if wave.next_vert >= wave.cur_vert else -1)


func _create_wave(src_pos: Vector2, speed: float) -> Dictionary:
	wave_id_counter += 1
	var cur_vert = _nearest_vertex_key(src_pos)
	var wave = {
		current_position = src_pos,
		cur_vert = cur_vert,
		next_vert = cur_vert, # unassigned for now
		speed = speed,
		travelled_distance = 0, # In pixels
		height = 16, # In pixel
		width = 32, # In pixels
		reduce = 8, # In pixels per second
		reduce_width = 0, # In pixels per second
		direction = 1, # Should be either 1 or -1
		height_direction = 1, # Should be either 1 or -1
		id = wave_id_counter,
	}
	wave.next_vertex = _next_vertex_key(wave)
	waves.append(wave)
	return wave


func _handle_impact(body, is_exit):
	if elapsed_time > 0 and (body.get("vel") == null or body.vel.y > 0): # Avoid objects triggering waves when spawning
		if !(body is CharacterBody2D or body is RigidBody2D):
			return
			
		var this_shape = shape_owner_get_shape(0, 0) # Get our shape
		var other_shape; var other_owner # Get the other shape and owner_id
		for owner_id in body.get_shape_owners():
			other_owner = owner_id
			other_shape = body.shape_owner_get_shape(owner_id, 0)
			break
		# Get the transforms
		var this_transform = shape_owner_get_owner(0).global_transform
		var other_transform = body.shape_owner_get_owner(other_owner).global_transform
		# Get the collision point
		var contacts = this_shape.collide_and_get_contacts(this_transform, other_shape, other_transform)
		if contacts.is_empty(): # If empty, well there's not much we can do then
			#print("why are there no contact points?")
			return
		var contact = contacts[0] # Get single contact point
		contact -= top_left_corner; # Transform it to local coordinates
		
		# Make the wave size dependent on impact and area
		var body_speed = 5.0
		if body.get("vel") != null:
			body_speed = abs(body.vel.y)
		
		# Pick sound effect based on impact speed
		if body_speed > 10:
			splash.stream = SPLASH_BANK["big"][randi() % 2]
		elif body_speed > 5:
			splash.stream = SPLASH_BANK["medium"][randi() % 2]
		else:
			splash.stream = SPLASH_BANK["small"][randi() % 2]
		
		splash.global_position = body.global_position
		splash.pitch_scale = randf_range(0.6, 1.4)
		splash.play()
		
		body_speed *= (0.5 if is_exit else 1.0)
		
		# Base values for the waves' size and speed
		var height_mult = sqrt(body_speed) / 4
		var speed_mult = sqrt(3 * body_speed) / 2
		# Factor in body's area
		var player_area = 348 # Player character's default area is the baseline
		var area_mult = 4 * (other_shape.size.x * other_shape.size.y / player_area)
		height_mult *= area_mult
		speed_mult *= area_mult
		
		# Create the waves
		var right = _create_wave(contact, 128)
		right.height *= height_mult
		right.speed *= speed_mult
		
		var left = _create_wave(contact, 128)
		left.height *= height_mult
		left.speed *= speed_mult
		left.direction = -1
		
		# Create trailing waves in the wake of the first two
		# (A trailing wave spawns each time a main wave travels its own width.)
		# We should only need to check the left wave because the right is always
		# exactly the same as it.
		var end_of_wave = left.width
		var og_wave_width = left.width
		var ind = 1
		while (left.height >= 1):
			if left.travelled_distance >= end_of_wave:
				var right_trail = _create_wave(contact, 128)
				right_trail.height *= height_mult / ind
				right_trail.speed *= speed_mult
				right_trail.height_direction = -1
				
				var left_trail = _create_wave(contact, 128)
				left_trail.height *= height_mult / ind
				left_trail.speed *= speed_mult
				left_trail.direction = -1
				left_trail.height_direction = -1 if (ind % 2) else 1
				
				ind += 1
				end_of_wave += og_wave_width
			
			await get_tree().process_frame
