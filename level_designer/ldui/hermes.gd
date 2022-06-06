extends AnimatedSprite

const edge_v_length = OS.window_size.y - 22
const edge_h_length = OS.window_size.x - 80 - 22

var speed = 0.2
var edge = 1
var progress = edge_h_length / 2

func set_pos(edge, progress) -> bool:
	match edge:
		0:
			position.x = 86.5
			position.y = progress
			rotation_degrees = 90
			if progress > edge_v_length || progress < 0:
				return true
		1:
			position.x = 80 + progress
			position.y = OS.window_size.y - 22 - 6.5
			rotation_degrees = 0
			if progress > edge_h_length || progress < 0:
				return true
		2:
			position.x = OS.window_size.x - 22 - 6.5
			position.y = OS.window_size.y - 22 - progress
			rotation_degrees = 270
			if progress > edge_v_length || progress < 0:
				return true
	
	return false


func _process(delta):
	var dmod = 60 * delta
	if Input.is_action_just_pressed("LD_select"):
		playing = true
	if !playing:
		if flip_h:
			progress -= speed * dmod
		else:
			progress += speed * dmod
	
	if set_pos(edge, progress):
		if flip_h:
			edge -= 1
			match edge:
				0:
					progress = edge_v_length
				1:
					progress = edge_h_length
				-1:
					progress = edge_v_length
					edge = 2
		else:
			edge += 1
			match edge:
				1:
					progress = 0
				2:
					progress = 0
				3:
					progress = 0
					edge = 0


func _on_Hermes_animation_finished():
	playing = false
	flip_h = !flip_h
	frame = 0
