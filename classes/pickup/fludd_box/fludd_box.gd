class_name FluddBox
extends Area2D

export(Singleton.n) var nozzle: int

var PICKUP_PREFABS = [
	preload("./fludd_pickup_hover.tscn"),
	preload("./fludd_pickup_rocket.tscn"),
	preload("./fludd_pickup_turbo.tscn"),
]
onready var sprite: AnimatedSprite = $AnimatedSprite


func _ready():
	sprite.animation = "stand_" + _get_nozzle_label(nozzle)


func _get_nozzle_label(id):
	match id:
		1:
			return "hover"
		2:
			return "rocket"
		3:
			return "turbo"
		_:
			Singleton.log_msg("Invalid nozzle type!", Singleton.LogType.ERROR)
			return null


func _on_FluddBox_body_entered(body):
	if body.vel.y > -2 and body.position.y < position.y: #TODO: give mario feet collision
		sprite.animation = "bounce_" + _get_nozzle_label(nozzle)
		
		var inst = PICKUP_PREFABS[nozzle - 1].instance()
		inst.position = Vector2(position.x, position.y + 8.5)
		get_parent().call_deferred("add_child", inst)
		
		Singleton.collected_nozzles[nozzle - 1] = true
		body.vel.y = -6 * 32 / 60
		$Open.play()
		set_deferred("monitoring", false)


func _on_AnimatedSprite_animation_finished():
	if sprite.animation.begins_with("bounce_"):
		sprite.animation = "open_" + _get_nozzle_label(nozzle)
	elif sprite.animation.begins_with("open_"):
		queue_free()
