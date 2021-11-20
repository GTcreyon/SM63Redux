extends Node

onready var serializer: Serializer = $Serializer
onready var base_modifier: BaseModifier = $BaseModifier

var classic = true

var nozzle = 0
var water = 100
var power = 100
var coin_total = 0
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

func _ready():
	rng.seed = hash("2401")
#	if enter != 0:
#		$"/root/Main/Player/Camera2D/GUI/SweepEffect".enter = enter
#		$"/root/Main/Player/Camera2D/GUI/SweepEffect".enter = direction
