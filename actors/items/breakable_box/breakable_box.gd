extends StaticBody2D

onready var player = $"/root/Main/Player"


func _ready():
	$Sprite.frame = randi() % 3


func _process(_delta):
	if $PoundArea.overlaps_body(player):
		if player.state == player.s.pound_fall:
			queue_free()
	if $SpinArea.overlaps_body(player):
		if player.state == player.s.spin && player.spin_timer > 0: 
			queue_free()

func _on_DetectionArea_body_entered(body):
	if ((player.state == player.s.pound_fall && body.global_position.y < global_position.y)
	|| (player.state == player.s.spin && player.spin_timer > 0)): 
		queue_free()


#only make it breakable when it's spinning towards its sides, and when it's only the first few nanoseconds of the spinning.
