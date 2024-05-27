@tool
class_name TerrainSkin
extends Resource

@export var body: Texture2D:
	set(value):
		if value != body:
			body = value
			emit_changed()

@export var top: Texture2D:
	set(value):
		if value != top:
			top = value
			emit_changed()

@export var top_clip: Texture2D:
	set(value):
		if value != top_clip:
			top_clip = value
			emit_changed()

@export var top_endcap: Texture2D:
	set(value):
		if value != top_endcap:
			top_endcap = value
			emit_changed()

@export var top_endcap_clip: Texture2D:
	set(value):
		if value != top_endcap_clip:
			top_endcap_clip = value
			emit_changed()

@export var side: Texture2D:
	set(value):
		if value != side:
			side = value
			emit_changed()

@export var bottom: Texture2D:
	set(value):
		if value != bottom:
			bottom = value
			emit_changed()
