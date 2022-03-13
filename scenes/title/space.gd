extends TextureRect

const SROLL_SPEED = 0.001

func _process(delta):
	anchor_left = fposmod(anchor_left - SROLL_SPEED, -2)
