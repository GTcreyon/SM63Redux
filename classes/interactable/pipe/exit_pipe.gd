extends Pipe

onready var sweep_effect = $"/root/Singleton/WindowWarp"

export var scene_path : String

func _warp(pos):
	sweep_effect.warp(pos, scene_path)
