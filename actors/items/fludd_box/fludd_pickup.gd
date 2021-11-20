extends KinematicBody2D

var vel = Vector2()

onready var singleton = $"/root/Singleton"
onready var player = $"/root/Main/Player"

onready var hover = $Hover
onready var rocket = $Rocket
onready var turbo = $Turbo

func switch_type(type):
	match type:
		2:
			hover.visible = false
			hover.monitoring = false
			rocket.visible = false
			rocket.monitoring = false
			turbo.visible = true
			turbo.monitoring = true
		1:
			hover.visible = false
			hover.visible = false
			rocket.visible = true
			rocket.visible = true
			turbo.visible = false
			turbo.visible = false
		_:
			hover.visible = true
			hover.monitoring = true
			rocket.visible = false
			rocket.monitoring = false
			turbo.visible = false
			turbo.monitoring = false


func pickup(nozzle):
	singleton.nozzle = nozzle
	singleton.water = max(singleton.water, 100)
	queue_free()


func _physics_process(_delta):
	if is_on_floor():
		vel.y = 0
	vel.y += 1.67
	# warning-ignore:RETURN_VALUE_DISCARDED
	move_and_slide(vel * 60, Vector2.UP, true)


func _on_Turbo_body_entered(_body):
	pickup(player.n.turbo)


func _on_Rocket_body_entered(_body):
	pickup(player.n.rocket)


func _on_Hover_body_entered(_body):
	pickup(player.n.hover)
