class_name EntityEnemyTarget
extends EntityEnemyWander

var target = null

export var _alert_area_path: NodePath = "AlertArea"
onready var alert_area = get_node(_alert_area_path)

export var _aware_area_path: NodePath = "AwareArea"
onready var aware_area = get_node(_aware_area_path)

func _ready_override():
	_entity_enemy_target_ready()


func _physics_step():
	_entity_enemy_target_physics_step()


func _entity_enemy_target_physics_step():
	_entity_physics_step()
	if target != null && target.locked:
		target = null
	if target == null:
		_entity_enemy_wander_behavior()
	else:
		_entity_enemy_target_behavior()


func _entity_enemy_target_behavior():
	if jump_state == JumpStates.FLOOR:
		_chase_target()


func _chase_target():
	sprite.speed_scale = abs(vel.x) / 2 + 1
	if target.position.x - position.x < -20 || (target.position.x < position.x && abs(target.position.y - position.y) < 26):
		vel.x = max(vel.x - 0.1, -2)
		mirror = true
		edge_check.position.x = -9
		sprite.playing = true
	elif target.position.x - position.x > 20 || (target.position.x > position.x && abs(target.position.y - position.y) < 26):
		vel.x = min(vel.x + 0.1, 2)
		mirror = false
		edge_check.position.x = 9
		sprite.playing = true
	else:
		vel.x *= 0.85
		if sprite.frame == 0:
			sprite.playing = false


func _on_AwareArea_body_exited(_body):
	target = null


func _on_AlertArea_body_entered(body):
	if target == null && !stomped && !body.locked:
		mirror = body.position.x < position.x
		target = body
		wander_dist = 0
		_target_alert()


func _target_alert():
	pass


func _entity_enemy_target_ready():
	_entity_enemy_ready()
	if alert_area == null:
		alert_area = get_node_or_null(_alert_area_path)
	if aware_area == null:
		aware_area = get_node_or_null(_aware_area_path)
	if alert_area != null:
		alert_area.connect("body_entered", self, "_on_AlertArea_body_entered")
	if aware_area != null:
		aware_area.connect("body_exited", self, "_on_AwareArea_body_exited")
