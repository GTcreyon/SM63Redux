extends Sprite

const GLOW_MATERIAL = preload("res://shaders/glow.tres")

onready var cam = $"/root/Main/Camera"
onready var main = $"/root/Main"
onready var control = $"/root/Main/UILayer/LDUI"
onready var property_menu = $"/root/Main/UILayer/PropertyMenu"


var item_id: int

var glow_factor = 1
var pulse = 0
var ghost = false
var properties: Dictionary = {}

func _selection_changed(new_selection):
	if new_selection.head == self:
#			if Input.is_action_pressed("LD_many"):
#				main.place_item(item_id)
		material = GLOW_MATERIAL
	else:
		material = null

func _ready():
	if ghost:
		modulate.a = 0.5
		position = main.snap_vector(get_global_mouse_position())
	$ClickArea/CollisionShape2D.shape.extents = texture.get_size() / 2
	
	main.connect("selection_changed", self, "_selection_changed")

func _input(event):
	if event.is_action_released("LD_place"):
		modulate.a = 1
		ghost = false

func _process(_delta):
	if ghost:
		position = main.snap_vector(get_global_mouse_position())
		properties["Position"] = position
	
	if material != null:
		pulse = fmod((pulse + 0.1), 2 * PI)
		material.set_shader_param("outline_color", Color(1, 1, 1, (sin(pulse) * 0.25 + 0.5) * glow_factor))
		
		if Input.is_action_just_pressed("ui_select"):
			property_menu.set_properties(properties, self)
			property_menu.show()


func set_property(label, value) -> void:
	properties[label] = value
	update_visual_property(label, value)


func update_visual_property(label, value) -> void:
	match label:
		"Disabled":
			item_disabled_tint(value)
		"Scale":
			scale = value
		"Rotation":
			rotation_degrees = float(value)
		"Mirror":
			flip_h = value


func item_disabled_tint(disabled) -> void:
	var val = 0.5 if disabled else 1.0
	modulate.r = val
	modulate.g = val
	modulate.b = val
