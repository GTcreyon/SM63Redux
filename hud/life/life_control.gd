extends Node2D

const start_pos = -75
const end_pos = 6
var end_adjust = end_pos

onready var player = $"/root/Main/Player"
onready var filler = $Filler
onready var save_count = player.life_meter_counter #for when variable gets changed
var act = false #for when life meter sprite can appear if true
var rechange_timer = 0
var rechange_trigger = false #so it can trigger the rechange_timer increment
var rechange_moving = false #after it's shown, it will return back up
var progress = 0

func _process(_delta):
	var gui_scale = floor(OS.window_size.y / 304)
	if get_tree().paused:
		progress = min(progress + 0.1, 1)
		end_adjust = lerp(end_adjust, end_pos + 18, 0.5)
		rechange_moving = true
	else:
		if !rechange_moving:
			end_adjust = lerp(end_adjust, end_pos, 0.5)
		if save_count != player.life_meter_counter: #if it changed
			save_count = player.life_meter_counter #for the conditional
			act = true #start life meter moving onto the screen
			#these are required for when the life meter gets affected while still showing up, will "last" longer on screen
			rechange_moving = false #in case it's going up
		
		if act:
			if progress < 1: #and then starts rechange_timer
				progress += 0.05
			if player.life_meter_counter == 8:
				act = false
			
			
		if player.life_meter_counter == 8:
			rechange_timer += 1
		else:
			rechange_timer = 0
		
		if rechange_timer >= 180: #if rechange_timer reaches 6 seconds
			rechange_timer = 0
			rechange_moving = true #then it will return to its initial position
		
		if player.life_meter_counter == 8:
			if rechange_moving:
				if progress > 0:
					progress -= 0.1
				else:
					rechange_moving = false #and now everything is back to place
			elif !act && !rechange_trigger && player.life_meter_counter >= 8:
				position.y = start_pos * gui_scale
		else:
			rechange_moving = false

		filler.frame = player.life_meter_counter #for the HUD with its respective frame
	position.y = (start_pos + sin(PI * progress / 2) * (end_adjust - start_pos)) * scale.y
