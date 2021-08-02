extends Node

var classic = true

var nozzle = 0
var water = 100
var power = 100
var coin_total = 0
var red_coin_total = 0
var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed = hash("2401")
