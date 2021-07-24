extends Node

var classic = true

var coin_total = 0
var red_coin_total = 0
var rng = RandomNumberGenerator.new()

func _ready():
	rng.seed = hash("2401")
