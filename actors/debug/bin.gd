extends Area2D

func _on_Bin_body_entered(body):
	body.queue_free()
