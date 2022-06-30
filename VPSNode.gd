extends Control

export var slots = []

func create_slot():
	var slot = {}
	var node = Control.new()
	var left_slot = TextureButton.new()
	var right_slot = TextureButton.new()
	slots.append(slot)
