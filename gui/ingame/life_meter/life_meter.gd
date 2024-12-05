extends Control

const START_POS = -35.0
const END_POS = 42.0

var end_adjust = END_POS

var act = false # For when life meter sprite can appear if true
var rechange_timer = 0
var rechange_trigger = false # So it can trigger the rechange_timer increment
var rechange_moving = false # After it's shown, it will return back up
var progress = 0
var coin_save = 0

@onready var player = $"/root/Main/Player"
@onready var filler = $MeterBase/Filler
@onready var coin_meter = $MeterBase/Filler/CoinMeter
@onready var coin_ring = $MeterBase/Filler/CoinMeter/CoinRing
@onready var death_cover = $"/root/Singleton/DeathManager/DeathCover"
@onready var save_count = player.hp # For when variable gets changed
@onready var power_indicator = $PowerIndicator

func _ready():
	coin_save = player.coins_toward_health
	modulate.v = 1 - death_cover.color.a
	progress = Singleton.meter_progress
	offset_top = (START_POS + sin(PI * progress / 2) * (end_adjust - START_POS)) * Singleton.get_screen_scale()
	filler.frame = player.hp


func _process(delta):
	# Health meter is on a layer above the death fade effect,
	# but it needs to fade out with the rest of the world to obscure the
	# health resetting.
	# Modulating the meter's brightness (value) does this flawlessly.
	modulate.v = 1 - death_cover.color.a
  
	var gui_scale = Singleton.get_screen_scale()
	var dmod = 60 * delta
	if Singleton.pause_menu:
		progress = min(progress + 0.1 * dmod, 1)
		end_adjust = lerp(end_adjust, END_POS + 18, 0.5)
		rechange_moving = true
	else:
		if !rechange_moving:
			end_adjust = lerp(end_adjust, END_POS, 0.5)
		if save_count != player.hp: # If it changed
			save_count = player.hp # For the conditional
			act = true # Start life meter moving onto the screen
			# These are required for when the life meter gets affected while still showing up, will "last" longer on screen
			rechange_moving = false # In case it's going up
		
		if act:
			if progress < 1: # And then starts rechange_timer
				progress += 0.05 * dmod
			if player.hp == 8:
				act = false
			
			
		if player.hp == 8:
			rechange_timer += 1 * dmod
		else:
			rechange_timer = 0
		
		if rechange_timer >= 180: # If rechange_timer reaches 6 seconds
			rechange_timer = 0
			rechange_moving = true # Then it will return to its initial position
		
		if player.hp == 8:
			if rechange_moving:
				if progress > 0:
					progress -= 0.1 * dmod
				else:
					rechange_moving = false # And now everything is back to place
			elif !act and !rechange_trigger and player.hp >= 8:
				offset_top = START_POS * gui_scale
		else:
			rechange_moving = false

		filler.frame = player.hp # For the HUD with its respective frame
		if player.coins_toward_health >= 5 and player.hp < 8:
			player.hp += 1
			player.coins_toward_health = 0
			coin_save = 0
			coin_meter.flash()
			power_indicator.flash()
		else:
			if coin_save != player.coins_toward_health:
				coin_meter.set_charge_level(player.coins_toward_health)
				power_indicator.set_charge_level(player.coins_toward_health)
				coin_save = player.coins_toward_health
		
		coin_ring.visible = (coin_meter.animation == "flash" and coin_meter.frame == 0)
	offset_top = (START_POS + sin(PI * progress / 2) * (end_adjust - START_POS))
	Singleton.meter_progress = progress
