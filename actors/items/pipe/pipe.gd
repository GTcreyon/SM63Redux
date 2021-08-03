extends StaticBody2D

#P.S: thanks godot for not making it easy to handle things

onready var player = $"/root/Main/Player"
onready var player_a = $"/root/Main/Player/AnimatedSprite"

onready var sound = $sfx #for sound effect

var i = 0 #This is the variable that will increase until it reaches 60
var inc = false #this variable will serve to trigger the increment as a "delay"
var can_warp = false #this variable is changed when mario enters the pipe's small area2D
var slid = false #this is necessary to tell godot to change mario's Y position to slide down

export var target_x_pos = 0 #the x value where mario will get teleported
export var target_y_pos = 0 #the y value where mario will get teleported

func _process(_delta):
	if (slid):
		if(player.state == 7):
			player.position.y = position.y
		else:
			if (player.position.y < position.y):
				player.position.y += 0.7
	
	if(Input.is_action_pressed("down") && can_warp):
		sound.play()
		player.static_v = true #affects mario's whole input process
		player_a.set_animation("front")
		player.position = Vector2(position.x, position.y - 30) #centers mario before he slides down
		
		#warping will be disabled, then increment will start as mario slides down
		can_warp = false
		inc = true
		slid = true
	elif(player.state == 7 && can_warp):
		sound.play()
		player.static_v = true #affects mario's whole input process
		player_a.set_animation("front")
		player.position = Vector2(position.x, position.y - 30) #centers mario before he slides down
		
		#warping will be disabled, then increment will start as mario slides down
		can_warp = false
		inc = true
		slid = true
	
	#the "delay" itself
	if(inc):
		i += 1
		
	if(i == 60): #mario then will be teleported as the "true" variables return to false
		sound.stop()
		player.position = Vector2(target_x_pos, target_y_pos)
		player.static_v = false
		player.switch_state(player.s.walk)
		i = 0
		inc = false
		slid = false

func _on_mario_top(body):
	if body.global_position.y < global_position.y:
		print("on top")
		if player.state == 4:
			can_warp = false
		else:
			can_warp = true #for being able to work all the stuff above

func _on_mario_off(_body):
		print("not on top")
		can_warp = false #or else he won't
