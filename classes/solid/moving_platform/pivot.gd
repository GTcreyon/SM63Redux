@tool
extends Node2D

const dot_tex = preload("./dot.png")
const platform = preload("./moving_platform.tscn")

@onready var group_platforms = $Platforms
@onready var group_dots = $Dots

@export var radius = 50: set = set_radius
@export var count = 3: set = set_count
@export var speed = 10.0
@export var offset = 0.0

var rot = 0.0


func _ready():
	refresh_ring()


func set_radius(new_radius):
	radius = new_radius
	refresh_ring() # Regenerate the ring with new radius


func set_count(new_count):
	count = new_count
	refresh_ring() # Regenerate the ring with new radius


func refresh_ring():
	for child in $Platforms.get_children(): # Clears children so the scene doesn't get cluttered
		child.queue_free()
	for child in $Dots.get_children():
		child.queue_free()
	
	# Generate platforms
	for i in range(count):
		var inst = platform.instantiate()
		var angle = (2 * PI / count) * i + offset # Split the circle into segments, find the i'th segment, then add offset
		inst.position = Vector2(cos(angle) * radius, sin(angle) * radius)
		$Platforms.add_child(inst)
	
	# Generate dots
	var circumference = 2 * PI * radius
	var dots = floor(circumference / 20) # This is the number of dots we'll generate
	for i in range(dots):
		var inst = Sprite2D.new()
		inst.texture = dot_tex
		var angle = (2 * PI / dots) * i
		inst.position = Vector2(cos(angle) * radius, sin(angle) * radius).round()
		$Dots.add_child(inst)


func _physics_process(_delta):
	if !Engine.is_editor_hint():
		for i in $Platforms.get_child_count():
			var angle = (2 * PI / count) * i + offset + rot
			$Platforms.get_child(i).position = Vector2(cos(angle) * radius, sin(angle) * radius)
		rot += (2 * PI / 360) * (speed / 10)
