extends Area2D

#settings for water
export var water_segment_size = 5 #in pixels, this works regardless of water scale.
export var surface_wave_properties = {
	width = 32, #in pixels
	height = 4, #in pixels
	speed = 1 #idk it just works
}

#private variables
onready var texture = $".."
onready var player = $"/root/Main/Player"

var waves = []
var surface = {}
var surface_width_keys = 0
var elapsed_time = 0
var wave_id_counter = 0

#subdivide the water surface
func subdivide_surface():
	var polys = PoolVector2Array()
	var size = texture.polygon.size()
	for i in range(0, size):
		var dir = texture.polygon[i].direction_to(texture.polygon[(i+1) % size])
		if dir == Vector2.RIGHT:
			var point = texture.polygon[i]
			while point.x < texture.polygon[(i+1) % size].x:
				polys.append(point)
				point += dir * water_segment_size
			if !polys[polys.size() - 1].is_equal_approx(texture.polygon[(i+1) % size]):
				polys.append(texture.polygon[(i+1) % size])
		else:
			polys.append(texture.polygon[i])
	
	set_polys(polys)
	surface = get_surface_verts()
	surface_width_keys = len(surface) - 1

func set_polys(polys):
	texture.polygon = polys

func get_surface_verts():
	var vertices = {}
	var size = texture.polygon.size()
	for i in size:
		if texture.polygon[i].direction_to(texture.polygon[(i + 1) % size]) == Vector2.RIGHT || texture.polygon[((i - 1) + size) % size].direction_to(texture.polygon[i]) == Vector2.RIGHT:
			vertices[i] = texture.polygon[i]
	return vertices

func set_surface_verts(dict):
	var copy = PoolVector2Array(texture.polygon)
	for k in dict.keys():
		copy.set(k, dict[k])
	set_polys(copy)

func get_nearest_surface_vertex_key(pos):
	var key
	var nearest_dist = INF
	for vertKey in surface.keys():
		var vert = surface[vertKey]
		var dist = (vert - pos).length()
		if dist < nearest_dist:
			key = vertKey
			nearest_dist = dist
	return key

func move_wave(wave, new):
	wave.current_position = new
	wave.current_vertex_key = get_nearest_surface_vertex_key(new)
	wave.next_vertex_key = get_next_vertex_key_for_wave(wave)
	wave.speed = wave.speed * (1 if wave.next_vertex_key >= wave.current_vertex_key else -1)

func create_wave(from, speed):
	wave_id_counter += 1
	var current_vertex_key = get_nearest_surface_vertex_key(from)
	var wave = {
		current_position = from,
		current_vertex_key = current_vertex_key,
		next_vertex_key = current_vertex_key,
		speed = speed,
		height = 16, #in pixel
		width = 32, #in pixels
		reduce = 8, #in pixels per second
		reduce_width = 0, #in pixels per second
		direction = 1, #should be either 1 or -1
		height_direction = 1, #should be either 1 or -1
		id = wave_id_counter,
	}
	wave.next_vertex = get_next_vertex_key_for_wave(wave)
	waves.append(wave)
	return wave

func get_next_vertex_key_for_wave(wave):
	var check_direction = (1 if wave.speed >= 0 else -1) * wave.direction
	#print(check_direction)
	if surface.has(wave.current_vertex_key + check_direction):
		return wave.current_vertex_key + check_direction
	elif surface.has(wave.current_vertex_key - check_direction):
		return wave.current_vertex_key - check_direction
	else:
		return wave.current_vertex_key

func _ready():
	#get the max x and max y
	#from the wiki I read textures can't be bigger than 16384x16384 pixels
	#so that means water can't be bigger than 16384x16384 pixels either (512x512 tiles)
	var max_x = 1; var max_y = 1
	for vertex in texture.polygon:
		if vertex.x >= max_x:
			max_x = vertex.x
		if vertex.y >= max_y:
			max_y = vertex.y
	
	#generate the texture for UV
	var img_texture = ImageTexture.new()
	var img = Image.new()
	#note: is there a less space needing format? it really only needs to store 2 colors, so 1 bit image format would work
	img.create(max_x, max_y, false, Image.FORMAT_RGB8)
	#make the texture white
	img.fill(Color(1, 1, 1, 1))
	img_texture.create_from_image(img)
	#set the texture
	texture.texture = img_texture

	#make the uv coords equal the one of the polygon BEFORE subdividing
	texture.uv = texture.polygon
	$Collision.polygon = texture.polygon
	
	#the water should be purely visual, so the uv and collision should be set before subdividing
	subdivide_surface()

#update the shader with the latest information
func _process(dt):
	elapsed_time += dt
	var pos = get_global_transform_with_canvas().origin #get the position
	var size = OS.get_window_size() #normalise the object
	pos.y = size.y - pos.y #inverse the y
	texture.material.set_shader_param("object_pos", pos / size) #give the object position to the shader
	
	var wave_y_modifier = {}
	for wave in waves:
		#first reduce the height
		wave.height -= wave.reduce * dt
		wave.width -= wave.reduce_width * dt
		#if our wave has become incredibly small, remove him
		if wave.height <= 2 || wave.width <= 2:
			waves.erase(wave)
			wave.height = 0 #do not skip the rest of the code, we set the wave height to 0 and it will clear itself up
		wave.current_position.x += wave.speed * wave.direction * dt
		#update the current and next vertex position, also flip the direction if needed
		if (wave.speed * wave.direction >= 0 && wave.current_position.x >= surface[wave.next_vertex_key].x) || (wave.speed * wave.direction <= 0 && wave.current_position.x <= surface[wave.next_vertex_key].x):
			wave.current_vertex_key = wave.next_vertex_key
			wave.next_vertex_key = get_next_vertex_key_for_wave(wave)
			wave.speed *= (1 if wave.next_vertex_key >= wave.current_vertex_key else -1) * sign(wave.speed * wave.direction)
		#get the min/max
		var ind_width = wave.width / water_segment_size
		var min_ind = round(wave.current_vertex_key - ind_width / 2)
		var max_ind = round(wave.current_vertex_key + ind_width / 2)
		#get the real min/max
		for ind in range(wave.current_vertex_key, min_ind - 1, -1):
			if not surface.has(ind):
				min_ind = ind + 1
				break
		for ind in range(wave.current_vertex_key, max_ind):
			if not surface.has(ind):
				max_ind = ind - 1
				break
		#get the width
		ind_width = max_ind - min_ind
		#generate a hill effect for this wave using sine
		var counter = 0
		for ind in range(min_ind, max_ind):
			#add the modifier
			var y_mod = -sin(float(counter) / float(ind_width) * PI) * wave.height * wave.height_direction
			counter += 1
			if wave_y_modifier.has(ind):
				wave_y_modifier[ind][wave.id] = y_mod
			else:
				wave_y_modifier[ind] = {[wave.id]: y_mod}

	#have a default wave effect
	var x_offset = get_global_transform().origin.x
	for surf_key in surface.keys():
		surface[surf_key].y = sin(
			(x_offset + surface[surf_key].x) * PI / surface_wave_properties.width
			+ elapsed_time * 2 * PI * surface_wave_properties.speed
		) * surface_wave_properties.height
	
	#apply the modifier
	for surf_key in wave_y_modifier.keys():
		for add_y in wave_y_modifier[surf_key].values():
			surface[surf_key].y += add_y

	#now actually set the verts
	set_surface_verts(surface)

func handle_impact(body, is_exit):
	var this_shape = shape_owner_get_shape(0, 0) #get our shape
	var other_shape; var other_owner #get the other shape and owner_id
	for owner_id in body.get_shape_owners():
		other_owner = owner_id
		other_shape = body.shape_owner_get_shape(owner_id, 0)
		break
	#get the transforms
	var this_transform = shape_owner_get_owner(0).global_transform
	var other_transform = body.shape_owner_get_owner(other_owner).global_transform
	#get the collision point
	var contacts = this_shape.collide_and_get_contacts(this_transform, other_shape, other_transform)
	if contacts.empty(): #if empty, well there's not much we can do then
		print("why are there no contact points?")
		return
	var contact = contacts[0] #get single contact point
	contact -= get_global_transform().origin #transform it to local coordinates
	
	#make the wave size dependant on impact and area
	var body_vel = 5
	if body.vel != null:
		body_vel = abs(body.vel.y)
	
	body_vel *= (0.5 if is_exit else 1.0)
	
	#impact velocity
	var mario_area = 348 #this is mario's default area
	var height_mult = sqrt(body_vel) / 2
	var speed_mult = sqrt(3 * body_vel) / 2
	
	#multiply area
	var area_mult = 4 * other_shape.extents.x * other_shape.extents.y / mario_area
	height_mult *= area_mult
	speed_mult *= area_mult
	
	#create the waves
	var right = create_wave(contact, 128)
	right.height *= height_mult
	right.speed *= speed_mult
	var left = create_wave(contact, 128)
	left.height *= height_mult
	left.speed *= speed_mult
	left.direction = -1

func _on_body_entered(body):
	handle_impact(body, false)
	if body == player:
		player.call_deferred("switch_state", player.s.swim)

func _on_body_exited(body):
	handle_impact(body, true)
	if body == player:
		player.call_deferred("switch_state", player.s.walk)
