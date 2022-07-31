class_name EntityEnemyTarget
extends EntityEnemyWander

var target = null

export var _alert_area_path: NodePath = "AlertArea"
onready var alert_area = get_node(_alert_area_path)

export var _aware_area_path: NodePath = "AwareArea"
onready var aware_area = get_node(_aware_area_path)

func _ready_override():
	_entity_enemy_ready()
	_entity_enemy_target_ready()


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
	if alert_area == null:
		alert_area = get_node_or_null(_alert_area_path)
	if aware_area == null:
		aware_area = get_node_or_null(_aware_area_path)
	if alert_area != null:
		alert_area.connect("body_entered", self, "_on_AlertArea_body_entered")
	if aware_area != null:
		aware_area.connect("body_exited", self, "_on_AwareArea_body_exited")
