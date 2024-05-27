class_name TerrainSkin
extends Resource

@export var body: Texture2D:
	set(value):
		if value != body:
			emit_changed()
		body = value

@export var top: Texture2D:
	set(value):
		if value != top:
			emit_changed()
		top = value

@export var top_clip: Texture2D:
	set(value):
		if value != top_clip:
			emit_changed()
		top_clip = value

@export var top_endcap: Texture2D:
	set(value):
		if value != top_endcap:
			emit_changed()
		top_endcap = value

@export var top_endcap_clip: Texture2D:
	set(value):
		if value != top_endcap_clip:
			emit_changed()
		top_endcap_clip = value

@export var side: Texture2D:
	set(value):
		if value != side:
			emit_changed()
		side = value

@export var bottom: Texture2D:
	set(value):
		if value != bottom:
			emit_changed()
		bottom = value
