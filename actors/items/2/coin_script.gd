extends Area2D

func update_classic():
	var classic = $"/root/Main".classic #this isn't a filename don't change Main to lowercase lol
	if classic:
		$Sprite.animation = "legacy"
	else:
		$Sprite.animation = "modern"

func _process(delta):
	if Input.is_action_just_pressed("debug"):
		update_classic()

func _on_Coin_body_entered_trigger(body): #another custom node made specifically for this object
	
	queue_free() #and 'destroys' the object when colliding
	
	pass # Replace with function body.
