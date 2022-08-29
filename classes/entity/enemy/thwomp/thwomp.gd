extends KinematicBody2D

var movement = Vector2()
onready var player = find_parent("Main").get_node("Player")
var can_go_down = false
var timer = 0
var return_to_pos = false
var og_pos_x = 0
var og_pos_y = 0

func _ready():
	og_pos_x = position.x
	og_pos_y = position.y

func go_down():
	movement.y += 50
	
	move_and_slide(movement)

func _physics_process(_delta):
	# If the player is nearby the object and the can_go_down variable is false, then it will go down
	if(abs(player.position.x - position.x) < 70 and !can_go_down):
		can_go_down = true
	# This can_go_down checks if the object is able to go down
	if(can_go_down):
		go_down()
	
	# This is to detect the floor but it detects other things like the player as well
	if $RayCast2D.is_colliding():
		can_go_down = false # Not able to go up
		return_to_pos = true # And now will return to its original position
	
	# Now it will return to its position
	if return_to_pos:
		# Timer starts here
		if(timer >= 120):
			#once the timer is up, then it will return to its position
			if(position.y > og_pos_y):
				movement.y -= 50
			elif(position.y <= og_pos_y):
				movement.y = 0
				position.y = og_pos_y
				# And set back the variaables to what they were originally
				timer = 0
				return_to_pos = false
			move_and_slide(movement)
		else:
			timer += 1


func _on_Hurtbox_body_entered(body):
	body.take_damage_shove(1, sign(body.position.x - position.x))
