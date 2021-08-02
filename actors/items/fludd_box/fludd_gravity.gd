extends KinematicBody2D

const GRAVITY = 10
const FLOOR = Vector2(0, -1)

var velocity = Vector2()

onready var main = $"/root/Main/Items/FluddBox".type
onready var singleton = $"/root/Singleton"
onready var player = $"/root/Main/Player"

onready var hover = $Hover
onready var rocket = $Rocket
onready var turbo = $Turbo

func switch_type(type):
	match type:
		2:
			hover.visible = false
			rocket.visible = false
			turbo.visible = true
		1:
			hover.visible = false
			rocket.visible = true
			turbo.visible = false
		_:
			hover.visible = true
			rocket.visible = false
			turbo.visible = false


func pickup(nozzle):
	singleton.nozzle = nozzle
	singleton.water = 100
	queue_free()


func _process(_delta):
	if Engine.editor_hint:
		switch_type(main)


func _ready():
	switch_type(main)


func _physics_process(_delta):
	velocity.y += GRAVITY
	
	velocity = move_and_slide(velocity, FLOOR)


func _on_Turbo_body_entered(_body):
	pickup(player.n.turbo)


func _on_Rocket_body_entered(_body):
	pickup(player.n.rocket)


func _on_Hover_body_entered(_body):
	pickup(player.n.hover)
