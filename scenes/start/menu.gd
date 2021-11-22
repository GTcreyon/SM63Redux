extends Control

onready var story = $Story
onready var settings = $Settings
onready var extra = $Extras
onready var ld = $LevelDesigner

onready var icon = $Icon
onready var border = $Border

var cycle_progress = 0
var cycle_direction = 0
var cycle_positions
var cycle_step = 0

func _process(_delta):
	var scale = floor(OS.window_size.y / 304)
	if Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
	if Input.is_action_just_pressed("screen+") && OS.window_size.x + 448 <= OS.get_screen_size().x && OS.window_size.y + 304 <= OS.get_screen_size().y:
		OS.window_size.x += 448
		OS.window_size.y += 304
	if Input.is_action_just_pressed("screen-") && OS.window_size.x - 448 >= 448:
		OS.window_size.x -= 448
		OS.window_size.y -= 304
		
	cycle_positions = [
		Vector2(OS.window_size.x / 2, (124.0 / 304.0) * OS.window_size.y),
		Vector2(OS.window_size.x - 4 * scale, (188.0 / 304.0) * OS.window_size.y),
		Vector2(OS.window_size.x / 2, OS.window_size.y + 100 * scale), #offscreen
		#Vector2.ZERO,
		Vector2(4 * scale, (188.0 / 304.0) * OS.window_size.y),
		]
	
	story.scale = Vector2.ONE * scale
	settings.scale = Vector2.ONE * scale
	extra.scale = Vector2.ONE * scale
	ld.scale = Vector2.ONE * scale
	
	icon.scale = Vector2.ONE * scale
	border.rect_scale = Vector2.ONE * scale
	border.margin_right = OS.window_size.x / scale
	border.margin_bottom = OS.window_size.y / scale
	
	if Input.is_action_just_pressed("right"):
		if cycle_direction == 1:
			cycle_step += 1
			cycle_progress = 0
		elif cycle_direction == -1:
			cycle_step -= 1
			cycle_progress = 2 * asin(1 - sin(cycle_progress*(PI/2)))/PI
		cycle_direction = 1
	
	if Input.is_action_just_pressed("left"):
		if cycle_direction == -1:
			cycle_step -= 1
			cycle_progress = 0
		elif cycle_direction == 1:
			cycle_step += 1
			cycle_progress = 2 * asin(1 - sin(cycle_progress*(PI/2)))/PI
			
		cycle_direction = -1
	
	var result = sin(cycle_progress * PI/2)
	story.position = lerp(cycle_positions[cycle_step % 4], cycle_positions[(cycle_step + cycle_direction) % 4], result)
	settings.position = lerp(cycle_positions[(cycle_step + 1) % 4], cycle_positions[(cycle_step + 1 + cycle_direction) % 4], result)
	extra.position = lerp(cycle_positions[(cycle_step + 2) % 4], cycle_positions[(cycle_step + 2 + cycle_direction) % 4], result)
	ld.position = lerp(cycle_positions[(cycle_step + 3) % 4], cycle_positions[(cycle_step + 3 + cycle_direction) % 4], result)
	
	if cycle_direction != 0:
		var outside = [story, settings, extra, ld][(cycle_direction - cycle_step) % 4]
		outside.position.x = lerp(cycle_positions[(2 - cycle_direction) % 4].x, OS.window_size.x / 2 + cycle_direction * OS.window_size.x, result)
		outside.position.y = lerp(cycle_positions[(2 - cycle_direction) % 4].y, OS.window_size.y, result)
		var inside = [story, settings, extra, ld][(2 * cycle_direction - cycle_step) % 4]
		inside.position.x = lerp(OS.window_size.x / 2 - cycle_direction * OS.window_size.x, cycle_positions[(2 + cycle_direction) % 4].x, result)
		inside.position.y = lerp(OS.window_size.y, cycle_positions[(2 + cycle_direction) % 4].y, result)
	
	if cycle_direction != 0:
		cycle_progress += 1 / 10.0
		if abs(cycle_progress) >= 1:
			cycle_step += cycle_direction
			#story.position = cycle_positions[cycle_step + cycle_direction]
			cycle_progress = 0
			cycle_direction = 0
