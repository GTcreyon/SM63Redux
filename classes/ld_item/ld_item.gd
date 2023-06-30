extends Sprite2D

const GLOW_MATERIAL = preload("res://shaders/glow.tres")

@onready var cam = $"/root/Main/Camera3D"
@onready var main = $"/root/Main"
@onready var control = $"/root/Main/UILayer/LDUI"
@onready var property_menu = $"/root/Main/UILayer/PropertyMenu"

var item_id: int

var glow_factor = 1
var pulse = 0
var ghost = false # If true, item has not been placed yet.
var properties: Dictionary = {}

func set_glowing(should_glow):
	if should_glow:
		material = GLOW_MATERIAL
	else:
		material = null


func _ready():
	if ghost:
		modulate.a = 0.5
		position = main.snap_vector(get_global_mouse_position())
	
	# Size my hitbox to match my texture
	$ClickArea/CollisionShape2D.shape.size = texture.get_size() / 2


func _input(event):
	# Instead of this guard, can we like disconnect the _input event?
	if !ghost:
		return
	
	if event.is_action_released("ld_place"):
		if Input.is_action_pressed("ld_keep_place"):
			# Copy this item in place
			var placed = duplicate()
			placed.item_id = item_id
			placed.properties = properties
			placed.position = position
			
			# Un-ghost the copy
			placed.modulate.a = 1
			placed.ghost = false
			
			# Put the copy in the scene
			get_parent().add_child(placed)
		else:
			# Un-ghost myself
			modulate.a = 1
			ghost = false
			# End placing-object state
			main.editor_state = main.EDITOR_STATE.IDLE
	elif event.is_action_released("ld_cancel_placement"):
		# Cancel placing me - delete myself and end placing state
		queue_free()
		main.editor_state = main.EDITOR_STATE.IDLE


func _process(_delta):
	if ghost:
		# Update my position to match the mouse
		position = main.snap_vector(get_global_mouse_position())
		properties["Position"] = position
	
	# If I have a glow material, make that pulse slowly
	if material != null:
		pulse = fmod((pulse + 0.1), 2 * PI)
		material.set_shader_parameter("outline_color", Color(1, 1, 1, (sin(pulse) * 0.25 + 0.5) * glow_factor))

func set_property(label, value) -> void:
	properties[label] = value
	update_visual_property(label, value)

func update_visual_property(label, value) -> void:
	match label:
		"Disabled":
			item_disabled_tint(value)
		"Scale":
			scale = value
		"Position":
			position = value
		"Rotation":
			rotation_degrees = float(value)
		"Mirror":
			flip_h = value


func item_disabled_tint(disabled) -> void:
	var val = 0.5 if disabled else 1.0
	modulate.r = val
	modulate.g = val
	modulate.b = val
