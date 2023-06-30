extends Area2D

@onready var cover = $CanvasLayer/Cover

var play_time = 0.0


func _process(delta):
	if play_time > 0:
		cover.size = get_window().size * 2
		cover.position = -get_window().size
		cover.color.a = sin(play_time * PI / 2) * 0.63
		play_time = min(play_time + 0.1, 1)


func _on_Shine_body_entered(body):
	play_time = 0.01
	body.locked = true
	body.collect_pos_final = position
	body.collect_pos_init = body.position
	body.collect_frames = 0
	body.camera.target_zoom /= 2
	body.camera.rezoom()
	body.z_index = 4096
	z_index = 4096
	$CollisionShape2D.queue_free()
	$SFX.play()
