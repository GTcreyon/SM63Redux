class_name EntityEnemyWander
extends EntityEnemy

enum JumpStates {
	FLOOR,
	LANDING,
	AIRBORNE,
}

var jump_state: int = JumpStates.FLOOR
var stepped = false
var wander_dist = 0

export var step_indexes = [false]

export var _edge_check_path: NodePath = "EdgeCheck"
onready var edge_check = get_node(_edge_check_path)

export var _sfx_step_path: NodePath = "SFXStep"
onready var sfx_step = get_node(_sfx_step_path)


func _physics_step():
	_entity_enemy_wander_behavior()


func _entity_enemy_wander_physics_step():
	_entity_physics_step()
	if step_indexes[sprite.frame]:
		if !stepped:
			sfx_step.pitch_scale = rand_range(0.9, 1.1)
			sfx_step.play()
			stepped = true
	else:
		stepped = false


func _entity_enemy_wander_behavior():
	if jump_state == JumpStates.FLOOR:
		if is_on_wall():
			vel.x = 0
			turn_around()
			wander_dist = 0
		
		edge_check.enabled = is_on_floor()
		
		if edge_check.enabled && !edge_check.is_colliding():
			turn_around()
		
		_wander()


func _wander():
	if sprite != null:
		sprite.speed_scale = 1
		sprite.playing = true
	if mirror:
		vel.x = max(vel.x - 0.1, -1)
	else:
		vel.x = min(vel.x + 0.1, 1)
	wander_dist += 1
	if wander_dist >= 120 && sprite.frame == 0:
		wander_dist = 0
		mirror = !mirror


func _entity_enemy_wander_disabled(val):
	_entity_enemy_disabled(val)
	if edge_check == null:
		edge_check = get_node_or_null(_edge_check_path)
	edge_check.enabled = !val


func set_disabled(val):
	_entity_enemy_wander_disabled(val)


func turn_around():
	mirror = !mirror
	edge_check.position.x *= -1
