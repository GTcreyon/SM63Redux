extends Area2D

onready var sprite = $AnimatedSprite

var crossed_item = false
var mario = null
var timer = 30


func _ready():
	sprite.playing = true


func _physics_process(_delta):
	if crossed_item:
		if Singleton.hp < 8:
			if timer >= 30:
				mario.recieve_health(1)
				timer = 0
			else:
				timer += 1
		else:
			crossed_item = false
			sprite.set_speed_scale(1.0)
			timer = 30
			mario = null


func _on_Heart_body_entered(body):
	crossed_item = true
	mario = body
	sprite.set_speed_scale(5.0)
