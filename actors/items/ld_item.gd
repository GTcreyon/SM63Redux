extends Sprite

const GLOW_MATERIAL = preload("res://shaders/glow.tres")

onready var cam = $"/root/Main/LDCamera"
onready var main = $"/root/Main"
onready var control = $"/root/Main/UILayer/LDUI"
onready var property_menu = $"/root/Main/UILayer/PropertyMenu"


export(String) var item_name

var glow_factor = 1
var pulse = 0
var ghost = false
var properties: Dictionary = {}

func _selection_changed(new_selection):
	if new_selection.head == self:
#			if Input.is_action_pressed("LD_many"):
#				main.place_item(item_name)
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

func _process(delta):
	if ghost:
		position = main.snap_vector(get_global_mouse_position())
	
	if material != null:
		pulse = fmod((pulse + 0.1), 2 * PI)
		material.set_shader_param("outline_color", Color(1, 1, 1, (sin(pulse) * 0.25 + 0.5) * glow_factor))
		
		if Input.is_action_just_pressed("ui_select"):
			print(properties["Disabled"]["value"])
			property_menu.set_properties(properties, self)
			property_menu.show()
