extends StaticBody2D

#P.S: thanks godot for not making it easy to handle things

onready var player = $"/root/Main/Player"
onready var player_a = $"/root/Main/Player/AnimatedSprite"

onready var sound = $sfx #for sound effect

var can_warp = false 	#this variable is changed when mario enters the pipe's small area2D
var slid = false 		#this is necessary to tell godot to change mario's Y position to slide down
var oncedown = true 	#this fixes an oversight where the player can hold down many times and makes sliding weird

export var target_x_pos = 0 #the x value where mario will get teleported
export var target_y_pos = 0 #the x value where mario will get teleported

func _process(_delta):
	#This whole process will not work until
	#slid is set to true, which is what happends after
	#mario changes to front sprite
	if slid:
		#this checks if mario is ground pounding or not
		if player.state == 7:
			player.position.y = position.y
		else:
			if player.position.y < position.y:
				player.position.y += 0.7
				
	if can_warp && Input.is_action_pressed("down") && oncedown:
		oncedown = false #set to false to avoid the player pressing down too many times
		
		player.static_v = true #affect's mario's whole input process
		can_warp = false #reset after being changed through body enetered/left signals
		player.position = Vector2(position.x, position.y - 30) #to center mario on top of the pipe
		player_a.set_animation("front") #changes mario sprite to front
		slid = true #to make mario's slide down effect
		sound.play()
		
		#this while thing if for a wait() like function, just delays for one second.
		#needed for slide down to finish
		var t = Timer.new()
		t.set_wait_time(1)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		
		#and then change mario's position to destination coordinates,
		#as well as enabling his input and then switching him to walk,
		#to avoid diving state
		sound.stop()
		player.position = Vector2(target_x_pos, target_y_pos)
		player.static_v = false
		player.switch_state(player.s.walk)
		
		oncedown = true #so the player can enter another pipe
		slid = false #to stop animation.
	elif can_warp && player.state == 7 && oncedown:
		#same as above but for groundpounding
		oncedown = false
		player.static_v = true
		can_warp = false
		
		player.position = Vector2(position.x, position.y - 30)
		
		slid = true
		sound.play()
		
		var t = Timer.new()
		t.set_wait_time(1)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		t.queue_free()
		
		sound.stop()
		player.position = Vector2(target_x_pos, target_y_pos)
		player.static_v = false
		player.switch_state(player.s.walk)
		
		oncedown = true
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
