class_name FluddBox
extends Area2D
# Box that drops a fludd nozzle when stomped.

@export var nozzle: FluddPickup.Nozzles# = FluddPickup.Nozzles.HOVER

var PICKUP_PREFABS = [
	preload("./fludd_pickup_hover.tscn"),
	preload("./fludd_pickup_rocket.tscn"),
	preload("./fludd_pickup_turbo.tscn"),
]

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


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


func _on_AnimatedSprite_animation_finished():
	if sprite.animation.begins_with("bounce_"):
		sprite.play("open_" + _get_nozzle_label(nozzle))
	elif sprite.animation.begins_with("open_"):
		queue_free()


func _on_FluddBox_area_entered(area):
	var player = area.get_parent()
	if player.vel.y > -2:
		sprite.animation = "bounce_" + _get_nozzle_label(nozzle)
		
		var inst = PICKUP_PREFABS[nozzle - 1].instantiate()
		inst.position = Vector2(position.x, position.y + 8.5)
		get_parent().call_deferred("add_child", inst)
		
		player.collected_nozzles[nozzle - 1] = true
		player.vel.y = -6.0 * 32.0 / 60.0
		$Open.play()
		set_deferred("monitoring", false)
