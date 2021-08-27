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
			$Hover.visible = false
			$Hover.monitoring = false
			$Rocket.visible = false
			$Rocket.monitoring = false
			$Turbo.visible = true
			$Turbo.monitoring = true
		1:
			$Hover.visible = false
			$Hover.visible = false
			$Rocket.visible = true
			$Rocket.visible = true
			$Turbo.visible = false
			$Turbo.visible = false
		_:
			$Hover.visible = true
			$Hover.monitoring = true
			$Rocket.visible = false
			$Rocket.monitoring = false
			$Turbo.visible = false
			$Turbo.monitoring = false


func pickup(nozzle):
	singleton.nozzle = nozzle
	singleton.water = 100
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
