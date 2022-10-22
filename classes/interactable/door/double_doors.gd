tool
extends Node2D

const SINGLE_DOOR_OFFSET = Vector2(8,0)

export var target_pos = Vector2.ZERO setget set_target_pos, get_target_pos
export var move_to_scene = false setget set_move_to_scene, get_move_to_scene
export var scene_path : String setget set_scene_path, get_scene_path

onready var door_l : Door = $Door_L
onready var door_r : Door = $Door_R


func set_target_pos(val):
	door_l = $Door_L
	door_r = $Door_R
	
	door_l.target_pos = val - SINGLE_DOOR_OFFSET
	door_r.target_pos = val + SINGLE_DOOR_OFFSET


func set_move_to_scene(val):
	door_l = $Door_L
	door_r = $Door_R
	
	door_l.move_to_scene = val
	door_r.move_to_scene = val


func set_scene_path(val):
	door_l = $Door_L
	door_r = $Door_R
	
	door_l.scene_path = val
	door_r.scene_path = val


func get_target_pos():
	door_l = $Door_L
	return door_l.target_pos + SINGLE_DOOR_OFFSET


func get_move_to_scene():
	door_l = $Door_L
	return door_l.move_to_scene


func get_scene_path():
	door_l = $Door_L
	return door_l.scene_path
