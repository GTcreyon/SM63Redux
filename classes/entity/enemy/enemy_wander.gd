class_name EntityEnemyWander
extends EntityEnemy

var stepped = false
var wander_dist = 0

export var _edge_check_path: NodePath = "EdgeCheck"
onready var edge_check = get_node(_edge_check_path)

export var _sfx_step_path: NodePath = "SFXStep"
onready var sfx_step = get_node(_sfx_step_path)


func _entity_enemy_wander_disabled(val):
	_entity_enemy_disabled(val)
	if edge_check == null:
		edge_check = get_node_or_null(_edge_check_path)
	edge_check.enabled = !val


func set_disabled(val):
	_entity_enemy_wander_disabled(val)
