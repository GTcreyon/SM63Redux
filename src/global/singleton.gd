extends Node

const DEFAULT_SIZE = Vector2(640, 360)
const VERSION = "v0.1.2"

onready var serializer: Serializer = $Serializer
onready var sm63_to_redux: SM63ToRedux = $"Serializer/SM63ToRedux"
onready var base_modifier: BaseModifier = $BaseModifier
onready var console = $Console
onready var timer = $Timer
onready var controls = $MobileControls

var classic = false

var nozzle = 0
var water = 100
var power = 100
var coin_total = 0
var internal_coin_counter = 0 #if it hits 5, gets reset
var red_coin_total = 0
var rng = RandomNumberGenerator.new()
var life_meter = 8
var enter = 0
var direction = 0
var dead = false
var hp = 8
var meter_progress = 0
var collected_nozzles = [false, false, false]
var collected_dict = {}
var collect_count = 0
var set_location
var flip
var pause_menu = false
var feedback = false
var line_count: int = 0

var disable_limits = false

enum LogType {
	INFO,
	WARNING,
	ERROR,
}

func log_msg(msg: String, type: int = LogType.INFO):
	var color_tag : String = "[color=#"
	match type:
		LogType.INFO:
			color_tag += "f9e8e8"
		LogType.WARNING:
			color_tag += "f2d67c"
		LogType.ERROR:
			color_tag += "f28d7c"
	color_tag += "]"
		
	console.logger.append_bbcode("\n" + color_tag + str(msg) + "[/color]")
	line_count += 1
	print(msg)
	

func _ready():
	#create_coindict(get_tree().get_current_scene().get_filename())
	rng.seed = hash("2401")
	collect_count = 0 # reset the collect count on every room load
#	if enter != 0:
#		$"/root/Main/Player/Camera2D/GUI/SweepEffect".enter = enter
#		$"/root/Main/Player/Camera2D/GUI/SweepEffect".enter = direction


func _process(_delta):
	var sfx = AudioServer.get_bus_index("SFX")
	var music = AudioServer.get_bus_index("Music")
	if Input.is_action_just_pressed("mute_sfx"):
		AudioServer.set_bus_mute(sfx, !AudioServer.is_bus_mute(sfx))
	if Input.is_action_just_pressed("volume_sfx-"):
		AudioServer.set_bus_volume_db(sfx, AudioServer.get_bus_volume_db(sfx) - 1)
	if Input.is_action_just_pressed("volume_sfx+"):
		AudioServer.set_bus_volume_db(sfx, AudioServer.get_bus_volume_db(sfx) + 1)
	if Input.is_action_just_pressed("mute_music"):
		AudioServer.set_bus_mute(music, !AudioServer.is_bus_mute(music))
	if Input.is_action_just_pressed("volume_music-"):
		AudioServer.set_bus_volume_db(music, AudioServer.get_bus_volume_db(music) - 1)
	if Input.is_action_just_pressed("volume_music+"):
		AudioServer.set_bus_volume_db(music, AudioServer.get_bus_volume_db(music) + 1)


func warp_to(path):
	collect_count = 0
	#create_coindict(path)
	if path == "res://scenes/tutorial_1/tutorial_1_1.tscn":
		timer.frames = 0
		timer.split_frames = 0
	timer.split_timer()
	#warning-ignore:RETURN_VALUE_DISCARDED
	get_tree().call_deferred("change_scene", path)


func get_collect_id():
	var path = get_tree().get_current_scene().get_filename()
	create_coindict(path)
	Singleton.collected_dict[path].append(false)
	collect_count += 1
	return collect_count - 1


func create_coindict(path):
	if !collected_dict.has(path):
		collected_dict[path] = [false]


func reset_all_coindicts():
	collected_dict = {}


func request_coin(collect_id):
	var room = get_tree().get_current_scene().get_filename()
	if !Singleton.collected_dict[room][collect_id]:
		Singleton.collected_dict[room][collect_id] = true
		return true
