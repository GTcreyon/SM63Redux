class_name InterSceneData
extends RefCounted # RefCounted counted because where to consistently free an Object?

var facing_direction: int # Direction player faces after a warp
var hp = 8
var coins_toward_health = 0 # If it hits 5, gets reset
var life_meter = 8 # apparently unused
var collected_nozzles = [false, false, false]
var current_nozzle = Singleton.Nozzles.NONE
var water = 100.0
var fludd_power = 100

func _init(player: PlayerCharacter):
	facing_direction = player.facing_direction

	hp = player.hp
	coins_toward_health = player.coins_toward_health
	life_meter = player.life_meter
	
	collected_nozzles = player.collected_nozzles
	current_nozzle = player.current_nozzle
	water = player.water
	fludd_power = player.fludd_power
