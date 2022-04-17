extends AnimatedSprite

var time = 0

func _ready():
	time = rand_range(0, 4 * 60)

func _process(delta):
	time -= 1 * 60 * delta
	if time <= 0:
		playing = true
		frame = 0
		time = rand_range(2 * 60, 3 * 60)
