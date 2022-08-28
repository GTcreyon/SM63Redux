extends Node2D

const start_pos = -75
const end_pos = 6
var end_adjust = end_pos

onready var player = $"/root/Main/Player"
onready var filler = $Filler
onready var coin_meter = $CoinMeter
onready var coin_ring = $CoinMeter/CoinRing
onready var death_cover = $"/root/Singleton/DeathCover"
onready var save_count = Singleton.hp #for when variable gets changed
var act = false #for when life meter sprite can appear if true
var rechange_timer = 0
var rechange_trigger = false #so it can trigger the rechange_timer increment
var rechange_moving = false #after it's shown, it will return back up
var progress = 0
var coin_save = 0

func _ready():
	coin_save = Singleton.internal_coin_counter
	modulate.v = 1 - death_cover.color.a
	progress = Singleton.meter_progress
	position.y = (start_pos + sin(PI * progress / 2) * (end_adjust - start_pos)) * max(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1)
	filler.frame = Singleton.hp


func _process(delta):
	var dmod = 60 * delta
	modulate.v = 1 - death_cover.color.a
	
	var gui_scale = max(floor(OS.window_size.x / Singleton.DEFAULT_SIZE.x), 1)
	if Singleton.pause_menu:
		progress = min(progress + 0.1 * dmod, 1)
		end_adjust = lerp(end_adjust, end_pos + 18, 0.5)
		rechange_moving = true
	else:
		if not rechange_moving:
			end_adjust = lerp(end_adjust, end_pos, 0.5)
		if save_count != Singleton.hp: #if it changed
			save_count = Singleton.hp #for the conditional
			act = true #start life meter moving onto the screen
			#these are required for when the life meter gets affected while still showing up, will "last" longer on screen
			rechange_moving = false #in case it's going up
		
		if act:
			if progress < 1: #and then starts rechange_timer
				progress += 0.05 * dmod
			if Singleton.hp == 8:
				act = false
			
			
		if Singleton.hp == 8:
			rechange_timer += 1 * dmod
		else:
			rechange_timer = 0
		
		if rechange_timer >= 180: #if rechange_timer reaches 6 seconds
			rechange_timer = 0
			rechange_moving = true #then it will return to its initial position
		
		if Singleton.hp == 8:
			if rechange_moving:
				if progress > 0:
					progress -= 0.1 * dmod
				else:
					rechange_moving = false #and now everything is back to place
			elif not act and not rechange_trigger and Singleton.hp >= 8:
				position.y = start_pos * gui_scale
		else:
			rechange_moving = false

		filler.frame = Singleton.hp #for the HUD with its respective frame
		if Singleton.internal_coin_counter >= 5 and Singleton.hp < 8:
			Singleton.hp += 1
			Singleton.internal_coin_counter = 0
			coin_save = 0
			coin_meter.frame = 0
			coin_meter.animation = "flash"
		else:
			if coin_meter.animation == "charge" or coin_save != Singleton.internal_coin_counter:
				coin_meter.animation = "charge"
				coin_meter.frame = Singleton.internal_coin_counter
				coin_save = Singleton.internal_coin_counter
		
		if coin_meter.animation == "flash" and coin_meter.frame == 6:
			coin_meter.animation = "charge"
		
		
		
		coin_ring.visible = (coin_meter.animation == "flash" and coin_meter.frame == 0)
	position.y = (start_pos + sin(PI * progress / 2) * (end_adjust - start_pos)) * scale.y
	Singleton.meter_progress = progress
