extends Area2D

func _on_Coin_body_entered_trigger(body): #another custom node made specifically for this object
	
	queue_free() #and 'destroys' the object when colliding
	
	pass # Replace with function body.
