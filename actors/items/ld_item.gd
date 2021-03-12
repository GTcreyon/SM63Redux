extends AnimatedSprite
const glow = preload("res://shaders/glow.tres")
var code = ""
var code_array = []
var glow_factor = 1
var pulse = 0.0
var selected = false
var size

onready var cam = get_parent().get_node("LDCamera")

func updateCode():
	code = ""
	for i in code_array:
		code += i + ","
	code.erase(code.length() - 1, 1)
	$Label.text = code

func _ready():
	$Label.text = code
	code_array = code.split(",")
	position = Vector2(int(code_array[1]) + 32, int(code_array[2]) + 32)
	animation = code_array[0]
	if animation != code_array[0]:
		animation = "0"
	if code_array[0] == "140":
		rotation_degrees = int(code_array[4])
	size = frames.get_frame(animation, frame).get_size()
	cam.connect("test_level", self, "_on_LDCamera_test_level")

func _process(delta):
	var i_left = Input.is_action_just_pressed("ui_left")
	var i_right = Input.is_action_just_pressed("ui_right")
	var i_up = Input.is_action_just_pressed("ui_up")
	var i_down = Input.is_action_just_pressed("ui_down")
	var i_place = Input.is_action_pressed("LD_place")
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
		code_array[1] = str(position.x - 32)
		code_array[2] = str(position.y - 32)
		updateCode()
	
	if code_array[0] == "1":
		get_parent().start_pos = position
		

func _on_LDCamera_test_level():
	if code_array[0] != "1":
		var object_spawn = cam.object_load(code_array[0]).instance()
		object_spawn.position = position
		get_parent().add_child(object_spawn)
	queue_free()

