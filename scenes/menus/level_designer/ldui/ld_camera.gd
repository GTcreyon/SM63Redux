extends Camera2D

signal test_level

const SCROLL_SPEED = 8

@onready var LD = get_parent()
@onready var music = LD.get_node("Music")

var mouse_pos = Vector2(0, 0)
var mouse_pos_store = Vector2(0, 0)
var objects_loaded = {}

const player = preload("res://classes/player/player.tscn")

func _ready():
	position = Vector2(-120, -get_window().size.y + 60)

func _process(_delta):
	var i_left = Input.is_action_pressed("ld_cam_left")
	var i_right = Input.is_action_pressed("ld_cam_right")
	var i_up = Input.is_action_pressed("ld_cam_up")
	var i_down = Input.is_action_pressed("ld_cam_down")
	var i_pan = Input.is_action_pressed("ld_cam_pan")
	mouse_pos = get_local_mouse_position()
	
	if i_pan:
		position += mouse_pos_store - mouse_pos
	else:
		var cam_move_x = int(i_right) - int(i_left)
		var cam_move_y = int(i_down) - int(i_up)
		position += Vector2(cam_move_x, cam_move_y) * SCROLL_SPEED
		
	mouse_pos_store = mouse_pos

	if i_down and Input.is_action_just_pressed("debug"):
		var player_spawn = player.instantiate()
		player_spawn.position = get_parent().start_pos
		get_parent().add_child(player_spawn)
		emit_signal("test_level")
		
	if i_right and Input.is_action_pressed("debug"):
		LD.save_code()

func object_load(id):
	if !objects_loaded.has(id):
		objects_loaded[id] = load("res://classes/items/" + str(id) + "/" + str(id) + ".tscn")
	return objects_loaded[id]

# Disabled this for now as I planned to use left drag for selecting items
#func _input(event):
#	if event is InputEventScreenDrag:
#		position -= event.relative
