class_name EntityEnemyWalk
extends EntityEnemy

var stepped = false
var wander_dist = 0
var target = null

@export var step_indexes: Array[bool] = [] # (Array, bool)

@export var _alert_area_path: NodePath = "AlertArea"
@onready var alert_area = get_node_or_null(_alert_area_path)

@export var _aware_area_path: NodePath = "AwareArea"
@onready var aware_area = get_node_or_null(_aware_area_path)

@export var _edge_check_path: NodePath = "EdgeCheck"
@onready var edge_check = get_node_or_null(_edge_check_path)

@export var _sfx_step_path: NodePath = "SFXStep"
@onready var sfx_step = get_node_or_null(_sfx_step_path)


func _preempt_all_node_readies():
	super._preempt_all_node_readies()
	edge_check = _preempt_node_ready(edge_check, _edge_check_path)
	alert_area = _preempt_node_ready(alert_area, _alert_area_path)
	aware_area = _preempt_node_ready(aware_area, _aware_area_path)


func _connect_signals():
	super._connect_signals()
	_connect_node_signal_if_exists(alert_area, "body_entered", self, "_on_AlertArea_body_entered")
	_connect_node_signal_if_exists(aware_area, "body_exited", self, "_on_AwareArea_body_exited")


func set_disabled(val):
	super.set_disabled(val)
	_set_node_property_if_exists(alert_area, "disabled", val)
	_set_node_property_if_exists(aware_area, "disabled", val)
	_set_node_property_if_exists(edge_check, "disabled", val)


func turn_around():
	mirror = !mirror
	if edge_check != null:
		edge_check.position.x *= -1


func _ready():
	super()
	if edge_check != null and mirror:
		edge_check.position.x *= -1


func _physics_step():
	super._physics_step()
	
	if stomped:
		return

	_manage_footsteps()

	if target != null and target.locked:
		target = null
	if target == null:
		_wander_behavior()
	else:
		_target_behavior()


func _manage_footsteps():
	if step_indexes[sprite.frame]:
		if !stepped:
			sfx_step.pitch_scale = randf_range(0.9, 1.1)
			sfx_step.play()
			stepped = true
	else:
		stepped = false


func _move_condition() -> bool:
	return is_on_floor()


func _target_behavior():
	if is_on_wall():
		vel.x = 0
	if _move_condition():
		_chase_target()


func _wander_behavior():
	if _move_condition():
		if is_on_wall():
			vel.x = 0
			turn_around()
			wander_dist = 0
		
		if edge_check != null:
			edge_check.enabled = is_on_floor()
			
			if edge_check.enabled and !edge_check.is_colliding():
				turn_around()
		
		_wander()


func _chase_target():
	sprite.speed_scale = abs(vel.x) / 2 + 1
	if target.position.x - position.x < -20 or (target.position.x < position.x and abs(target.position.y - position.y) < 26):
		vel.x = max(vel.x - 0.1, -2)
		mirror = true
		sprite.play()
		if edge_check != null:
			edge_check.position.x = -9
	elif target.position.x - position.x > 20 or (target.position.x > position.x and abs(target.position.y - position.y) < 26):
		vel.x = min(vel.x + 0.1, 2)
		mirror = false
		sprite.play()
		if edge_check != null:
			edge_check.position.x = 9
	else:
		vel.x *= 0.85
		if sprite.frame == 0:
			sprite.stop()


func _wander():
	if sprite != null:
		sprite.speed_scale = 1
		sprite.play()
	if mirror:
		vel.x = max(vel.x - 0.1, -1)
	else:
		vel.x = min(vel.x + 0.1, 1)
	wander_dist += 1
	if wander_dist >= 120 and sprite.frame == 0:
		wander_dist = 0
		mirror = !mirror


func _on_AwareArea_body_exited(_body):
	target = null


func _on_AlertArea_body_entered(body):
	if target == null and !stomped and !body.locked:
		mirror = body.position.x < position.x
		target = body
		wander_dist = 0
		_target_alert(body)


func _target_alert(_body):
	pass
