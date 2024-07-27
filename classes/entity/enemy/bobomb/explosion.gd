extends Area2D

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D


func _ready():
	sprite.play()


func _process(_delta):
	if sprite.frame < 4:
		collision.shape.radius = 10 + sprite.frame * 3
	else:
		monitoring = false
	if sprite.frame == 10:
		queue_free()
