extends AnimatedSprite2D

const EDGE_V_LENGTH = get_window().size.y - 22
const EDGE_H_LENGTH = get_window().size.x - 80 - 22
const EDGE_L_POS = 96
const EDGE_M_POS = 0
const EDGE_R_POS = 0
const CENTRE_OFFSET = 6.5

var speed = 0.2
var edge = 1
var progress = EDGE_H_LENGTH / 2


func set_pos(edge, progress) -> bool:
	match edge:
		0:
			position.x = EDGE_L_POS + CENTRE_OFFSET
			position.y = progress + CENTRE_OFFSET
			rotation_degrees = 90
			if progress > EDGE_V_LENGTH or progress < 0:
				return true
		1:
			position.x = EDGE_L_POS + progress
			position.y = get_window().size.y - EDGE_M_POS - CENTRE_OFFSET
			rotation_degrees = 0
			if progress > EDGE_H_LENGTH or progress < 0:
				return true
		2:
			position.x = get_window().size.x - EDGE_R_POS - CENTRE_OFFSET
			position.y = get_window().size.y - EDGE_R_POS - progress
			rotation_degrees = 270
			if progress > EDGE_V_LENGTH or progress < 0:
				return true
	
	return false


func _process(delta):
	var dmod = 60 * delta
	if Input.is_action_just_pressed("ld_select"):
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
					progress = EDGE_V_LENGTH
				1:
					progress = EDGE_H_LENGTH
				-1:
					progress = EDGE_V_LENGTH
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
