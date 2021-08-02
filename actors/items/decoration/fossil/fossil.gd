tool
extends AnimatedSprite
 
func _ready():
	frame = randi() % 3
	if animation == "yellow": #make caps rarer
		if frame == 2:
			if randi() % 5 != 0:
				frame = randi() % 2
