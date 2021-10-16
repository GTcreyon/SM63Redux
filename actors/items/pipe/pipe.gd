extends StaticBody2D

#P.S: thanks godot for not making it easy to handle things

onready var player = $"/root/Main/Player"
onready var player_sprite = $"/root/Main/Player/AnimatedSprite"
onready var player_sfx = $"/root/Main/Player/Voice"

onready var sound = $sfx #for sound effect

var i = 0 #This is the variable that will increase until it reaches 60
var inc = false #this variable will serve to trigger the increment as a "delay"
var can_warp = false #this variable is changed when mario enters the pipe's small area2D
var slid = false #this is necessary to tell godot to change mario's Y position to slide down
var store_state = 0

export var target_x_pos = 0 #the x value where mario will get teleported
export var target_y_pos = 0 #the y value where mario will get teleported

func _process(_delta):
	if slid:
		if player.state == 7:
			player.position.y = position.y
			player.position.x = lerp(player.position.x, position.x, 0.75)
		else:
			player.position.x = lerp(player.position.x, position.x, 0.25)
			if player.position.y < position.y:
				player.position.y += 0.7
	
	if Input.is_action_pressed("down") && can_warp && store_state == player.s.walk && player.is_on_floor():
		player_sfx.volume_db = -INF #dumb solution to mario making dive sounds
		sound.play()
		player.static_v = true #affects mario's whole input process
		player_sprite.set_animation("front")
		player.position = Vector2(lerp(player.position.x, position.x, 0.25), position.y - 30)
		#warping will be disabled, then increment will start as mario slides down
		can_warp = false
		inc = true
		slid = true
	elif player.state == player.s.pound_fall && can_warp:
		sound.play()
		player.static_v = true #affects mario's whole input process
		#player.position = Vector2(position.x, position.y - 30)
		player.position = Vector2(lerp(player.position.x, position.x, 0.75), position.y - 30)
		
		#warping will be disabled, then increment will start as mario slides down
		can_warp = false
		inc = true
		slid = true
	
	store_state = player.state
	
	#the "delay" itself
	if inc:
		i += 1
		
	if i == 60: #mario then will be teleported as the "true" variables return to false
		player_sfx.volume_db = -5
		sound.stop()
		player.position = Vector2(target_x_pos, target_y_pos)
		player.static_v = false
		player.switch_state(player.s.walk)
		player.switch_anim("walk")
		player.dive_correct(0)
		i = 0
		inc = false
		slid = false

func _on_mario_top(body):
	if body.global_position.y < global_position.y:
		#print("on top")
		if player.state == 0:
			can_warp = true
		else:
			can_warp = false
		
		if player.state == 4:
			can_warp = false
		else:
			can_warp = true #for being able to work all the stuff above

func _on_mario_off(_body):
		#print("not on top")
		can_warp = false #or else he won't
