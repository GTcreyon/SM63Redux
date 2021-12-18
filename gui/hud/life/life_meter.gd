extends Node2D

const start_pos = -75
const end_pos = 6
var end_adjust = end_pos

onready var player = $"/root/Main/Player"
onready var filler = $Filler
onready var coin_meter = $CoinMeter
onready var coin_ring = $CoinMeter/CoinRing
onready var singleton = $"/root/Singleton"
onready var death_cover = $"/root/Singleton/DeathCover"
onready var save_count = singleton.hp #for when variable gets changed
var act = false #for when life meter sprite can appear if true
var rechange_timer = 0
var rechange_trigger = false #so it can trigger the rechange_timer increment
var rechange_moving = false #after it's shown, it will return back up
var progress = 0
var coin_save = 0

func _ready():
	coin_save = singleton.internal_coin_counter
	modulate.v = 1 - death_cover.color.a
	progress = singleton.meter_progress
	position.y = (start_pos + sin(PI * progress / 2) * (end_adjust - start_pos)) * floor(OS.window_size.y / Singleton.DEFAULT_SIZE.y)
	filler.frame = singleton.hp


func _process(_delta):
	modulate.v = 1 - death_cover.color.a
	
	var gui_scale = floor(OS.window_size.y / Singleton.DEFAULT_SIZE.y)
	if get_tree().paused:
		progress = min(progress + 0.1, 1)
		end_adjust = lerp(end_adjust, end_pos + 18, 0.5)
		rechange_moving = true
	else:
		if !rechange_moving:
			end_adjust = lerp(end_adjust, end_pos, 0.5)
		if save_count != singleton.hp: #if it changed
			save_count = singleton.hp #for the conditional
			act = true #start life meter moving onto the screen
			#these are required for when the life meter gets affected while still showing up, will "last" longer on screen
			rechange_moving = false #in case it's going up
		
		if act:
			if progress < 1: #and then starts rechange_timer
				progress += 0.05
			if singleton.hp == 8:
				act = false
			
			
		if singleton.hp == 8:
			rechange_timer += 1
		else:
			rechange_timer = 0
		
		if rechange_timer >= 180: #if rechange_timer reaches 6 seconds
			rechange_timer = 0
			rechange_moving = true #then it will return to its initial position
		
		if singleton.hp == 8:
			if rechange_moving:
				if progress > 0:
					progress -= 0.1
				else:
					rechange_moving = false #and now everything is back to place
			elif !act && !rechange_trigger && singleton.hp >= 8:
				position.y = start_pos * gui_scale
		else:
			rechange_moving = false

		filler.frame = singleton.hp #for the HUD with its respective frame
		if singleton.internal_coin_counter >= 5 && singleton.hp < 8:
			singleton.hp += 1
			singleton.internal_coin_counter = 0
			coin_save = 0
			coin_meter.frame = 0
			coin_meter.animation = "flash"
		else:
			if coin_meter.animation == "charge" || coin_save != singleton.internal_coin_counter:
				coin_meter.animation = "charge"
				coin_meter.frame = singleton.internal_coin_counter
				coin_save = singleton.internal_coin_counter
		
		if coin_meter.animation == "flash" && coin_meter.frame == 6:
			coin_meter.animation = "charge"
		
		
		
		coin_ring.visible = (coin_meter.animation == "flash" && coin_meter.frame == 0)
	position.y = (start_pos + sin(PI * progress / 2) * (end_adjust - start_pos)) * scale.y
	singleton.meter_progress = progress
