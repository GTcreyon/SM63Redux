extends StaticBody2D

onready var sound = $sfx #for sound effect

var i = 0 #This is the variable that will increase until it reaches 60
var inc = false #this variable will serve to trigger the increment as a "delay"
var can_warp = false #this variable is changed when mario enters the pipe's small area2D
var slid = false #this is necessary to tell godot to change mario's Y position to slide down
var store_state = 0
var target = null

export var target_x_pos = 0 #the x value where mario will get teleported
export var target_y_pos = 0 #the y value where mario will get teleported

func _physics_process(_delta):
	if slid:
		if target.state == 7:
			target.position.y = position.y
			target.position.x = lerp(target.position.x, position.x, 0.75)
		else:
			target.position.x = lerp(target.position.x, position.x, 0.25)
			if target.position.y < position.y:
				target.position.y += 0.7
	
	if can_warp:
		if Input.is_action_pressed("down") && store_state == target.s.walk && target.is_on_floor():
			target.get_node("Voice").volume_db = -INF #dumb solution to mario making dive sounds
			sound.play()
			target.static_v = true #affects mario's whole input process
			target.get_node("Character").set_animation("front")
			target.position = Vector2(lerp(target.position.x, position.x, 0.25), position.y - 30)
			#warping will be disabled, then increment will start as mario slides down
			can_warp = false
			inc = true
			slid = true
		elif (target.state == target.s.pound_fall || target.state == target.s.pound_land):
			sound.play()
			target.static_v = true #affects mario's whole input process
			#target.position = Vector2(position.x, position.y - 30)
			target.position = Vector2(lerp(target.position.x, position.x, 0.75), position.y - 30)
			
			#warping will be disabled, then increment will start as mario slides down
			can_warp = false
			inc = true
			slid = true
	
		store_state = target.state
	
	#the "delay" itself
	if inc:
		i += 1
		
	if i == 60: #mario then will be teleported as the "true" variables return to false
		target.get_node("Voice").volume_db = -5
		sound.stop()
		target.position = Vector2(target_x_pos, target_y_pos)
		target.static_v = false
		target.switch_state(target.s.walk)
		target.switch_anim("walk")
		target.dive_correct(0)
		i = 0
		inc = false
		slid = false

func _on_mario_top(body):
	if body.global_position.y < global_position.y:
		#print("on top")
		if body.state == body.s.walk:
			can_warp = true
			target = body

func _on_mario_off(_body):
		#print("not on top")
		can_warp = false #or else he won't
		target = null
