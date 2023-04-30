extends Control

onready var inner = $Inner
onready var outer = $Outer

var switch_frame: int = 0


func transition(frame: int) -> void:
	outer.play("switch")
	outer.frame = 0
	switch_frame = frame


func _process(_delta) -> void:
	if outer.frame == 3:
		inner.frame = switch_frame


func _on_Outer_animation_finished():
	outer.play("idle")
