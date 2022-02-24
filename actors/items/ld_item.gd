extends AnimatedSprite

const glow = preload("res://shaders/glow.tres")

var id = ""
var data = []

var glow_factor = 1
var pulse = 0.0
var selected = false
var size

onready var cam = get_parent().get_node("LDCamera")

func _ready():
	size = frames.get_frame(animation, frame).get_size()

func _process(_delta):
	var i_left = Input.is_action_just_pressed("ui_left")
	var i_right = Input.is_action_just_pressed("ui_right")
	var i_up = Input.is_action_just_pressed("ui_up")
	var i_down = Input.is_action_just_pressed("ui_down")
	var i_select = Input.is_action_just_pressed("LD_select")
	var i_select_h = Input.is_action_pressed("LD_select")
	var i_precise = Input.is_action_pressed("LD_precise")
	var shift_step = 16
	if i_select:
		if Rect2(position - size/2, size).has_point(get_global_mouse_position()):
			selected = true
			material = glow
		else:
			selected = false
			material = null
			pulse = 0.0
	if selected:
		material.set_shader_param("outline_color",Color(1, 1, 1, (sin(pulse)*0.25+0.5)*glow_factor))
		#var a = (sin(pulse)*0.25+0.5)*glow_factor
		pulse = fmod((pulse + 0.1), 2*PI)
		if i_select_h:
			position = get_global_mouse_position()
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
