extends Node

const DEFAULT_SIZE = Vector2(640, 360)
const VERSION = "v0.2.0.alpha"
const LD_VERSION = 0
const LOCALES = [
	["en", "English"],
	["es", "Español"],
	["fr", "Français"],
	["it", "Italiano"],
	["nl", "Nederlands"],
]


enum n { # FLUDD enum
	none,
	hover,
	rocket,
	turbo,
}

onready var GameStateManager = $GameStateManager
onready var InputManager = $InputManager


onready var console = $Console
onready var timer = $Timer

var classic = false

#TODO: Maybe find better places for this stuff?
#====================================
var nozzle = 0
var water: float = 100.0
var power = 100
var coin_total = 0
var internal_coin_counter = 0 # If it hits 5, gets reset
var red_coin_total = 0
var rng = RandomNumberGenerator.new()
var life_meter = 8
var enter = 0
var direction = 0
var dead = false
var hp = 8
var meter_progress = 0
var collected_nozzles = [false, false, false]
var set_location
var flip
var pause_menu = false
#====================================
var line_count: int = 0
var disable_limits = false
var touch_control = false
var ld_buffer = PoolByteArray([])
var meta_paused = false #TODO: make irrelevant with gamestatemanager
var meta_pauses = {
	"feedback":false,
	"console":false,
}


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
	touch_control = OS.get_name() == "Android"
	rng.seed = hash("2401")


func _process(_delta):
	var sfx = AudioServer.get_bus_index("SFX")
	var music = AudioServer.get_bus_index("Music")
	if Input.is_action_just_pressed("volume_sfx-"):
		AudioServer.set_bus_volume_db(sfx, AudioServer.get_bus_volume_db(sfx) - 1)
	if Input.is_action_just_pressed("volume_sfx+"):
		AudioServer.set_bus_volume_db(sfx, AudioServer.get_bus_volume_db(sfx) + 1)
	if Input.is_action_just_pressed("volume_music-"):
		AudioServer.set_bus_volume_db(music, AudioServer.get_bus_volume_db(music) - 1)
	if Input.is_action_just_pressed("volume_music+"):
		AudioServer.set_bus_volume_db(music, AudioServer.get_bus_volume_db(music) + 1)


func warp_to(path):
	FlagServer.reset_assign_id()
	if path == "res://scenes/tutorial_1/tutorial_1_1.tscn":
		timer.running = true
		timer.frames = 0
		timer.split_frames = 0
	timer.split_timer()
	# warning-ignore:RETURN_VALUE_DISCARDED
	get_tree().call_deferred("change_scene", path)


# Sets a certain pause label - when all pause labels are false, gameplay takes place
func set_pause(label: String, set: bool):
	meta_pauses[label] = set
	meta_paused = false
	for pause in meta_pauses:
		meta_paused = meta_paused or meta_pauses[pause]


func list_files_in_directory(path): #credit to volzhs on the Godot Q&A forum
	var files = []
	var dir = Directory.new()
	if dir.dir_exists(path):
		dir.open(path)
		dir.list_dir_begin()

		while true:
			var file = dir.get_next()
			if file == "":
				break
			elif not file.begins_with("."):
				files.append(file)

		dir.list_dir_end()

		return files
	else:
		push_error("%s.list_files_in_directory(): Path '%s' does not exist!" % [self.name, path])
