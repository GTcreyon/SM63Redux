extends Node2D

const SINGLE_DOOR_OFFSET = Vector2(8,0)

export var sprite : SpriteFrames
export var target_pos = Vector2.ZERO
export var move_to_scene = false
export var scene_path : String

onready var door_l : Door = $Door_L
onready var door_r : Door = $Door_R

func _ready():
	# When run in game, populate child doors with my data
	if !Engine.editor_hint:
		door_l = $Door_L
		door_r = $Door_R
		
		$Door_L/DoorSprite.frames = sprite
		$Door_R/DoorSprite.frames = sprite
		
		door_l.target_pos = target_pos - SINGLE_DOOR_OFFSET
		door_r.target_pos = target_pos + SINGLE_DOOR_OFFSET
		
		door_l.move_to_scene = move_to_scene
		door_r.move_to_scene = move_to_scene
		
		door_l.scene_path = scene_path
		door_r.scene_path = scene_path

