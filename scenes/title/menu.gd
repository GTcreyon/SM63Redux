extends Control

const descriptions = [
	"Take the light back from Bowser and save the Mushroom Kingdom!",
	"Create your own worlds in this in-depth Level Designer!",
	"Enjoy a collection of trinkets and goodies!",
	"Adjust anything and everything to your liking!"
]

onready var selector_story = $SelectorStory
onready var selector_settings = $SelectorSettings
onready var selector_extra = $SelectorExtras
onready var selector_ld = $SelectorLevelDesigner

onready var story = $Story
onready var settings = $Settings
onready var extra = $Extras
onready var ld = $LevelDesigner

onready var icon = $Icon
onready var border = $Border
onready var description = $Border/Description

var cycle_progress = 0
var cycle_direction = 0
var cycle_positions
var cycle_step = 0

func _process(_delta):
	var scale = floor(OS.window_size.y / Singleton.DEFAULT_SIZE.y)
		
	cycle_positions = [
		Vector2(OS.window_size.x / 2, (124.0 / Singleton.DEFAULT_SIZE.y) * OS.window_size.y),
		Vector2(OS.window_size.x - 4 * scale, (188.0 / Singleton.DEFAULT_SIZE.y) * OS.window_size.y),
		Vector2(OS.window_size.x / 2, OS.window_size.y + 100 * scale), #offscreen
		#Vector2.ZERO,
		Vector2(4 * scale, (188.0 / Singleton.DEFAULT_SIZE.y) * OS.window_size.y),
		]
	
	story.scale = Vector2.ONE * scale
	settings.scale = Vector2.ONE * scale
	extra.scale = Vector2.ONE * scale
	ld.scale = Vector2.ONE * scale
	selector_story.scale = Vector2.ONE * scale
	selector_settings.scale = Vector2.ONE * scale
	selector_extra.scale = Vector2.ONE * scale
	selector_ld.scale = Vector2.ONE * scale
	
	icon.scale = Vector2.ONE * scale
	border.rect_scale = Vector2.ONE * scale
	border.margin_right = OS.window_size.x / scale
	border.margin_bottom = OS.window_size.y / scale
	
	if Input.is_action_just_pressed("left"):
		Singleton.get_node("SFX/Next").play()
		if cycle_direction == 1:
			cycle_step += 1
			cycle_progress = 0
		elif cycle_direction == -1:
			cycle_step -= 1
			cycle_progress = 2 * asin(1 - sin(cycle_progress*(PI/2)))/PI
		cycle_direction = 1
	
	if Input.is_action_just_pressed("right"):
		Singleton.get_node("SFX/Next").play()
		if cycle_direction == -1:
			cycle_step -= 1
			cycle_progress = 0
		elif cycle_direction == 1:
			cycle_step += 1
			cycle_progress = 2 * asin(1 - sin(cycle_progress*(PI/2)))/PI
			
		cycle_direction = -1
	
	var result = sin(cycle_progress * PI/2)
	var offset = Vector2.DOWN * 45 * scale
	selector_story.position = lerp(cycle_positions[cycle_step % 4] + offset, cycle_positions[(cycle_step + cycle_direction) % 4] + offset, cycle_progress)
	selector_settings.position = lerp(cycle_positions[(cycle_step + 1) % 4] + offset, cycle_positions[(cycle_step + 1 + cycle_direction) % 4] + offset, cycle_progress)
	selector_extra.position = lerp(cycle_positions[(cycle_step + 2) % 4] + offset, cycle_positions[(cycle_step + 2 + cycle_direction) % 4] + offset, cycle_progress)
	selector_ld.position = lerp(cycle_positions[(cycle_step + 3) % 4] + offset, cycle_positions[(cycle_step + 3 + cycle_direction) % 4] + offset, cycle_progress)
	
	story.position = lerp(cycle_positions[cycle_step % 4], cycle_positions[(cycle_step + cycle_direction) % 4], result)
	settings.position = lerp(cycle_positions[(cycle_step + 1) % 4], cycle_positions[(cycle_step + 1 + cycle_direction) % 4], result)
	extra.position = lerp(cycle_positions[(cycle_step + 2) % 4], cycle_positions[(cycle_step + 2 + cycle_direction) % 4], result)
	ld.position = lerp(cycle_positions[(cycle_step + 3) % 4], cycle_positions[(cycle_step + 3 + cycle_direction) % 4], result)
	
	if cycle_direction != 0:
		var arr = [[story, selector_story], [settings, selector_settings], [extra, selector_extra], [ld, selector_ld]]
		var outside = arr[(cycle_direction - cycle_step) % 4]
		outside[0].position.x = lerp(cycle_positions[(2 - cycle_direction) % 4].x, OS.window_size.x / 2 + cycle_direction * OS.window_size.x, result)
		outside[0].position.y = lerp(cycle_positions[(2 - cycle_direction) % 4].y, OS.window_size.y, result)
		outside[1].position.x = lerp(cycle_positions[(2 - cycle_direction) % 4].x, OS.window_size.x / 2 + cycle_direction * OS.window_size.x, cycle_progress)
		outside[1].position.y = lerp(cycle_positions[(2 - cycle_direction) % 4].y, OS.window_size.y, cycle_progress)
		var inside = arr[(2 * cycle_direction - cycle_step) % 4]
		inside[0].position.x = lerp(OS.window_size.x / 2 - cycle_direction * OS.window_size.x, cycle_positions[(2 + cycle_direction) % 4].x, result)
		inside[0].position.y = lerp(OS.window_size.y, cycle_positions[(2 + cycle_direction) % 4].y, result)
		inside[1].position.x = lerp(OS.window_size.x / 2 - cycle_direction * OS.window_size.x, cycle_positions[(2 + cycle_direction) % 4].x, cycle_progress)
		inside[1].position.y = lerp(OS.window_size.y, cycle_positions[(2 + cycle_direction) % 4].y, cycle_progress)
	
	if cycle_direction != 0:
		cycle_progress += 1 / 12.0
		if abs(cycle_progress) >= 1:
			cycle_step += cycle_direction
			cycle_progress = 0
			cycle_direction = 0
	
	var arr = [story, ld, extra, settings]
	for node in arr:
		node.get_node("Frame/CrystalL").frame = 0
		node.get_node("Frame/CrystalR").frame = 0
	arr[cycle_step % 4].get_node("Frame/CrystalL").frame = 1
	arr[cycle_step % 4].get_node("Frame/CrystalR").frame = 1
	
	description.text = TranslationServer.translate(descriptions[(cycle_step + cycle_direction) % 4])
	
	if Input.is_action_just_pressed("ui_accept") || Input.is_action_just_pressed("interact"):
		match (cycle_step + cycle_direction) % 4:
			0:
				Singleton.get_node("WindowWarp").warp(Vector2(110, 153), "res://scenes/tutorial_1/tutorial_1_1.tscn")
				Singleton.get_node("SFX/Start").play()
	
