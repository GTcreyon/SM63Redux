extends Node

onready var serializer: Serializer = $Serializer
onready var base_modifier: BaseModifier = $BaseModifier

var classic = true

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
var kris = false
var meter_progress = 0
var collected_nozzles = [false, false, false]
var collected_dict = {}
var collect_count = 0

func _ready():
	var file = get_tree().get_current_scene().get_filename()
	if !collected_dict.has(file):
		collected_dict[file] = []
	rng.seed = hash("2401")
	collect_count = 0 # reset the collect count on every room load
#	if enter != 0:
#		$"/root/Main/Player/Camera2D/GUI/SweepEffect".enter = enter
#		$"/root/Main/Player/Camera2D/GUI/SweepEffect".enter = direction


func warp_to(path):
	collect_count = 0
	if !path in collected_dict:
		collected_dict[path] = []
	#warning-ignore:RETURN_VALUE_DISCARDED
	return get_tree().change_scene(path)


func get_collect_id():
	Singleton.collected_dict[get_tree().get_current_scene().get_filename()].append(false)
	collect_count += 1
	return collect_count - 1
