extends Sprite

const glow = preload("res://shaders/glow.tres")

onready var cam = get_parent().get_node("LDCamera")
onready var main = $"/root/Main"
onready var control = $"/root/Main/UILayer/LDUI"

var glow_factor = 1
var pulse = 0.0
var selected = false
var size
var ghost = false
var mouse_in = false
var item_name
var drag_offset = Vector2.ZERO

func _ready():
	$ClickArea/CollisionShape2D.shape.extents = texture.get_size() / 2


func _process(_delta):
	var i_left = Input.is_action_just_pressed("ui_left")
	var i_right = Input.is_action_just_pressed("ui_right")
	var i_up = Input.is_action_just_pressed("ui_up")
	var i_down = Input.is_action_just_pressed("ui_down")
	var i_select = Input.is_action_just_pressed("LD_select")
	var i_select_h = Input.is_action_pressed("LD_select")
	var i_precise = Input.is_action_pressed("LD_precise")
	var shift_step = 16
	if ghost:
		if i_select:
			ghost = false
			if Input.is_action_pressed("LD_many"):
				main.place_item(item_name)
		position = get_global_mouse_position()
		modulate.a = 0.5
	else:
		if i_select:
			drag_offset = position - get_global_mouse_position()
			selected = false
			if mouse_in:
				main.request_select(self)
		modulate.a = 1
		if selected:
			material = glow
		else:
			material = null
			pulse = 0.0
		if selected:
			material.set_shader_param("outline_color",Color(1, 1, 1, (sin(pulse)*0.25+0.5)*glow_factor))
			#var a = (sin(pulse)*0.25+0.5)*glow_factor
			pulse = fmod((pulse + 0.1), 2*PI)
			if i_select_h:
				position = get_global_mouse_position() + drag_offset
			else:
				if i_precise:
					shift_step = 1
				if i_left:
					position.x -= shift_step
				if i_right:
					position.x += shift_step
				if i_up:
					position.y -= shift_step
				if i_down:
					position.y += shift_step


#func _on_ClickArea_input_event(viewport, event, shape_idx):
#	if event is InputEventMouseButton:
#		if event.pressed:
#			selected = true


func _on_ClickArea_mouse_entered():
	mouse_in = true


func _on_ClickArea_mouse_exited():
	mouse_in = false
