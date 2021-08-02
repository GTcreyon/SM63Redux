tool
extends Node2D

export(int, 1) var type = 0

onready var singleton = $"/root/Singleton"
onready var big = $BottleBig
onready var small = $BottleSmall

func switch_type(new_type):
	match new_type:
		1:
			$BottleBig.visible = true
			$BottleBig.monitoring = true
			$BottleSmall.visible = false
			$BottleSmall.monitoring = false
		_:
			$BottleBig.visible = false
			$BottleBig.monitoring = false
			$BottleSmall.visible = true
			$BottleSmall.monitoring = true
			
func _process(_delta):
	if Engine.editor_hint:
		switch_type(type)

func _ready():
	switch_type(type)

func _on_BottleBig_body_entered(_body):
	if !Engine.editor_hint:
		singleton.water = min(singleton.water + 50, 100)
		queue_free()


func _on_BottleSmall_body_entered(_body):
	if !Engine.editor_hint:
		singleton.water = min(singleton.water + 15, 100)
		queue_free()
