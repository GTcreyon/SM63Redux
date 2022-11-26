extends InteractableWarp


func _animation_length() -> int:
	return 120 if move_to_scene else 90


func _begin_animation(_player):
	_player.switch_anim("jump") # Temp--need back-facing jump anim


func _update_animation(_frame, _player):
	pass


func _end_animation(_player):
	#Reset player to full size and visibility.
	_player.scale = Vector2(1,1)
	_player.sprite.modulate.a = 1
