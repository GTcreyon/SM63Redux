tool
extends Node2D

export(int, 1) var type = 0

onready var player = $"/root/Main/Player"
onready var big = $BottleBig
onready var small = $BottleSmall

func switch_type(type):
	match type:
		1:
			big.visible = true
			big.monitoring = true
			small.visible = false
			small.monitoring = false
		_:
			big.visible = false
			big.monitoring = false
			small.visible = true
			small.monitoring = true
			
func _process(_delta):
	if Engine.editor_hint:
		switch_type(type)

func _ready():
	switch_type(type)

func _on_BottleBig_body_entered(_body):
	if !Engine.editor_hint:
		player.water = min(player.water + 50, 100)
		queue_free()


func _on_BottleSmall_body_entered(_body):
	if !Engine.editor_hint:
		player.water = min(player.water + 15, 100)
		queue_free()
