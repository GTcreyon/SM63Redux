class_name Entity
extends KinematicBody2D
# Root class for all entities that move in any way.
# Entities have the Entity collision layer bit enabled, so they can influence weights.
# They have water collision built-in.

const GRAVITY = 0.17
const TERM_VEL_AIR = 6
const TERM_VEL_WATER = 2

export var disabled = false setget set_disabled
var vel = Vector2.ZERO
var _water_bodies: int = 0


func _physics_process(_delta):
	_physics_step()


func _wall_contact():
	pass


func _physics_step():
	if !disabled:
		if _water_bodies > 0:
			vel.y = min(vel.y + GRAVITY, TERM_VEL_WATER)
		else:
			vel.y = min(vel.y + GRAVITY, TERM_VEL_AIR)
		
		if is_on_floor():
			if is_on_wall():
				_wall_contact()
		
		var snap
		if is_on_floor() && vel.y >= 0:
			snap = Vector2(0, 4)
		else:
			snap = Vector2.ZERO
		
		#warning-ignore:RETURN_VALUE_DISCARDED
		move_and_slide_with_snap(vel * 60, snap, Vector2.UP, true)


func _on_WaterCheck_area_entered(_area):
	_water_bodies += 1


func _on_WaterCheck_area_exited(_area):
	_water_bodies -= 1


func _entity_disabled(val):
	disabled = val
	set_collision_layer_bit(0, 0 if val else 1)


func set_disabled(val):
	_entity_disabled(val)
