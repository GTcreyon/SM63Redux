extends AnimatedSprite
const glow = preload("res://Shaders/Glow.tres");
var code = "";
var codeArray = [];
var glowFactor = 1;
var pulse = 0.0;
var selected = false;
var size;

onready var cam = get_parent().get_node("LDCamera");

func updateCode():
	code = "";
	for i in codeArray:
		code += i + ","
	code.erase(code.length() - 1, 1);
	$Label.text = code;

func _ready():
	$Label.text = code;
	codeArray = code.split(",");
	position = Vector2(int(codeArray[1]) + 32, int(codeArray[2]) + 32);
	animation = codeArray[0];
	if animation != codeArray[0]:
		animation = "0";
	if codeArray[0] == "140":
		rotation_degrees = int(codeArray[4]);
	size = frames.get_frame(animation, frame).get_size();
	cam.connect("test_level", self, "_on_LDCamera_test_level");

func _process(delta):
	var iLeft = Input.is_action_just_pressed("ui_left");
	var iRight = Input.is_action_just_pressed("ui_right");
	var iUp = Input.is_action_just_pressed("ui_up");
	var iDown = Input.is_action_just_pressed("ui_down");
	var iPlace = Input.is_action_pressed("LD_place");
	var iSelect = Input.is_action_just_pressed("LD_select");
	var iSelectH = Input.is_action_pressed("LD_select");
	var iPrecise = Input.is_action_pressed("LD_precise");
	var shiftStep = 16;
	if iSelect:
		if Rect2(position - size/2, size).has_point(get_global_mouse_position()):
			selected = true;
			material = glow;
		else:
			selected = false;
			material = null;
			pulse = 0.0;
	if selected:
		material.set_shader_param("outline_color",Color(1, 1, 1, (sin(pulse)*0.25+0.5)*glowFactor));
		#var a = (sin(pulse)*0.25+0.5)*glowFactor;
		pulse = fmod((pulse + 0.1), 2*PI);
		if iSelectH:
			position = get_global_mouse_position();
		else:
			if iPrecise:
				shiftStep = 1;
			if iLeft:
				position.x -= shiftStep;
			if iRight:
				position.x += shiftStep;
			if iUp:
				position.y -= shiftStep;
			if iDown:
				position.y += shiftStep;
		codeArray[1] = str(position.x - 32);
		codeArray[2] = str(position.y - 32);
		updateCode();
	
	if codeArray[0] == "1":
		get_parent().startPos = position;
		

func _on_LDCamera_test_level():
	if codeArray[0] != "1":
		var objectSpawn = cam.object_load(codeArray[0]).instance();
		objectSpawn.position = position;
		get_parent().add_child(objectSpawn);
	queue_free();

