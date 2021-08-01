tool
extends Node2D

export var length = 56 setget set_length

func set_length(new_length):
	length = new_length
	$Texture.rect_size.y = length
