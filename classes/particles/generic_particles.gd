class_name GenericParticles2D
extends Node2D
## Generic class for GPUParticles2D and CPUParticles2D

var g_emitting: bool = false:
	set(value):
		set(&"emitting", value)
		g_emitting = value
	get:
		return get(&"emitting")
