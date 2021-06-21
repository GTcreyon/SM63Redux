extends Area2D

onready var player = $"/root/Main/Player"
onready var sweep_effect = $"/root/Main/Player/Camera2D/GUI/SweepEffect" 
export var set_location = Vector2()
var turn_on = false
func _ready():
	sweep_effect.rect_position.x = -800
	sweep_effect.rect_position.y = 0
	
func _physics_process(delta):
	if turn_on == true:
		sweep_effect.rect_position.x += 20
	if sweep_effect.rect_position.x == -200 and turn_on == true:
		player.position = set_location
	if sweep_effect.rect_position.x == 1500:
		sweep_effect.set_visible(false)
		turn_on = false
func _on_WarpZone_body_entered(body):
	sweep_effect.set_visible(true)
	turn_on = true
	sweep_effect.rect_position.x = -800
