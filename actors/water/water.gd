extends Area2D

#settings for water
export var water_segment_size = 5 #in pixels, this works regardless of water scale.
export var impact = {"force": 30, "range": 50, "max_damp_range": 0.2, "damping_per_second": 0.95} #values in pixels, pixels, percentage, percentage
export var multipliers = {"wave": 1,"impact": 1} #have multipliers to impact and wave height
export var wave = {"width": 30, "height": 5, "speed": 1.5} #if speed is negative then the direction flips

#private variables
onready var texture = $Texture
var surface = {}
var global_surface = {} #read only!!!
var addon_surface = {}
var elapsed_time = 0

#utility functions
func set_polys(polys): #set the shape of the water for the collision and texture (note, disabled collision)
	#var shape = shape_owner_get_shape(0, 0)
	#shape.set_point_cloud(polys)
	texture.polygon = polys

func subdivide_surface(): #subdivide the water surface
	var polys = PoolVector2Array()
	for x in range(0, 32 * scale.x, water_segment_size):
		polys.append(Vector2(x / scale.x, 0))
	if !polys[polys.size() - 1].is_equal_approx(Vector2(32, 0)):
		polys.append(Vector2(32, 0))
	polys.append(Vector2(32, 32))
	polys.append(Vector2(0, 32))
	set_polys(polys)
	var surf = get_surface_verts()
	surface = surf
	global_surface = transform_polygons_dict(surf, true)
	var addon = {}
	for k in surf.keys():
		addon[k] = 0
	addon_surface = addon

func get_surface_verts():
	var dict = {}
	for i in texture.polygon.size():
		var vert = texture.polygon[i]
		if vert.y != 32:
			dict[i] = vert
	return dict

func set_surface_verts(dict):
	var copy = PoolVector2Array(texture.polygon)
	for k in dict.keys():
		copy.set(k, dict[k])
	set_polys(copy)

func transform_polygons_dict(dict, to_global):
	dict = dict.duplicate()
	for k in dict.keys():
		var vert = dict[k]
		if to_global:
			vert = vert * scale + position
		else:
			vert = (vert - position) / scale
		dict[k] = vert
	return dict
	
func transform_polygons_dict_float(dict, to_global):
	dict = dict.duplicate()
	for k in dict.keys():
		var y_pos = dict[k]
		if to_global:
			y_pos = y_pos * scale.y + position.y
		else:
			y_pos = (y_pos - position.y) / scale.y
		dict[k] = y_pos
	return dict

func _ready():
	subdivide_surface()

#update the shader with the latest information
func _process(dt):
	elapsed_time += dt
	var pos = get_global_transform_with_canvas().origin #get the position
	var size = OS.get_window_size() #normalise the object
	pos.y = size.y - pos.y #inverse the y
	material.set_shader_param("object_pos", pos / size) #give the object position to the shader
	
	var real_surf = get_surface_verts()
	#var transformed = transform_polygons_dict(surface, true)
	for k in surface.keys():
		#surface[i].y *= 0.95
		addon_surface[k] *= (1 - impact.damping_per_second * dt) * multipliers.impact
		surface[k].y = sin(elapsed_time * PI * wave.speed + (surface[k].x * PI * scale.x) / wave.width + position.x * PI) * multipliers.wave
		real_surf[k] = surface[k] / Vector2(1, scale.y / wave.height) + Vector2(0, addon_surface[k] / scale.y * 5)
		real_surf[k].y = min(real_surf[k].y, 31.99)
	set_surface_verts(real_surf)

func _on_Water_body_entered(body):
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
		return
	var contact = contacts[0] #get single contact point
	
	var body_y_vel = 0
	if body.get("vel") != null:
		body_y_vel = body.vel.y * 0.2 #make the body velocity have an impact on the wave size
		#if the collision doesn't have a velocity, then use the default
	var global = transform_polygons_dict_float(addon_surface, true) #transform it back to global space
	var max_size = 32 * scale.x * impact.max_damp_range #full max is 32 * scale.x
	for k in global.keys():
		var dist = contact.distance_to(global_surface[k]) #get the distance
		var f = cos(dist / impact.range * PI * 1.5) #make the wave effect
		var g = max(-dist / max_size + 1, 0) #damping effect
		var real_impact = f * g * impact.force * body_y_vel #get the real impact
		global[k] += real_impact
	addon_surface = transform_polygons_dict_float(global, false)
	#print(addon_surface)
	#set_surface_verts(local) #set the surface polygons
