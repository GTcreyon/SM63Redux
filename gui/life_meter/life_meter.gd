extends Control

const start_pos = -35
const end_pos = 42
var end_adjust = end_pos

onready var player = $"/root/Main/Player"
onready var filler = $MeterBase/Filler
onready var coin_meter = $MeterBase/Filler/CoinMeter
onready var coin_ring = $MeterBase/Filler/CoinMeter/CoinRing
onready var death_cover = $"/root/Singleton/DeathCover"
onready var save_count = Singleton.hp # For when variable gets changed
var act = false # For when life meter sprite can appear if true
var rechange_timer = 0
var rechange_trigger = false # So it can trigger the rechange_timer increment
var rechange_moving = false # After it's shown, it will return back up
var progress = 0
var coin_save = 0


func _ready():
	coin_save = Singleton.internal_coin_counter
	modulate.v = 1 - death_cover.color.a
	progress = Singleton.meter_progress
	margin_top = (start_pos + sin(PI * progress / 2) * (end_adjust - start_pos)) * Singleton.get_screen_scale()
	filler.frame = Singleton.hp


func _process(delta):
	var dmod = 60 * delta
	modulate.v = 1 - death_cover.color.a
	
	var gui_scale = Singleton.get_screen_scale()
	if Singleton.pause_menu:
		progress = min(progress + 0.1 * dmod, 1)
		end_adjust = lerp(end_adjust, end_pos + 18, 0.5)
		rechange_moving = true
	else:
		if !rechange_moving:
			end_adjust = lerp(end_adjust, end_pos, 0.5)
		if save_count != Singleton.hp: # If it changed
			save_count = Singleton.hp # For the conditional
			act = true # Start life meter moving onto the screen
			# These are required for when the life meter gets affected while still showing up, will "last" longer on screen
			rechange_moving = false # In case it's going up
		
		if act:
			if progress < 1: # And then starts rechange_timer
				progress += 0.05 * dmod
			if Singleton.hp == 8:
				act = false
			
			
		if Singleton.hp == 8:
			rechange_timer += 1 * dmod
		else:
			rechange_timer = 0
		
		if rechange_timer >= 180: # If rechange_timer reaches 6 seconds
			rechange_timer = 0
			rechange_moving = true # Then it will return to its initial position
		
		if Singleton.hp == 8:
			if rechange_moving:
				if progress > 0:
					progress -= 0.1 * dmod
				else:
					rechange_moving = false # And now everything is back to place
			elif !act and !rechange_trigger and Singleton.hp >= 8:
				margin_top = start_pos * gui_scale
		else:
			rechange_moving = false

		filler.frame = Singleton.hp # For the HUD with its respective frame
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
	margin_top = (start_pos + sin(PI * progress / 2) * (end_adjust - start_pos))
	Singleton.meter_progress = progress
