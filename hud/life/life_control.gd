extends Node2D

onready var player = $"/root/Main/Player"
onready var filler = $Filler
onready var lifs = player.life_meter_counter #for when variable gets changed
var act = false #for when life meter sprite can appear if true
var tim = 0 #"timer"
var del = false #so it can trigger the timer increment
var rechange = false #after it's shown, it will return back up

func _process(_delta):
	if get_tree().paused:
		var gui_scale = floor(OS.window_size.y / 304)
		position.y = lerp(position.y, 40 + 18 * gui_scale - 36, 0.5)
		rechange = true
	else:
		if lifs != player.life_meter_counter: #if it changed
			#these are required for when the life meter gets affected while still showing up, will "last" longer on screen
			if del:
				tim = 60
			elif rechange:
				tim = 60
				rechange = false #in case it's going up
				
			lifs = player.life_meter_counter #for the conditional
			act = true
			
		if position.y < 40 - 36 && act:
			position.y = lerp(position.y, 8, 0.3) #since it's in _process, it will keep adding until conditional stops being true
			if position.y >= 40 - 36: #and then starts timer
				act = false
				del = true
			
		if del:
			tim += 1
		
		if tim == 180: #if timer reaches 6 seconds
			tim = 0
			del = false
			rechange = true #then it will return to its initial position
		
		if rechange:
			if position.y > -80 - 72 * scale.y && player.life_meter_counter > 7:
				position.y = lerp(position.y, -140, 0.3)
			else:
				rechange = false #and now everything is back to place
		elif !act && !del && player.life_meter_counter >= 8:
			position.y = -80 - 72 * scale.y
		
		if player.life_meter_counter == 8:
			del = true
		
		filler.frame = player.life_meter_counter #for the HUD with its respective frame
		
