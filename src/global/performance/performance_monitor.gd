extends Node

var data: Dictionary = {
#var fps: int = 60
#var process_time: float
#var physics_time: float
#var objects: int = 0
#var resources: int = 0
#var nodes: int = 0
#var orphans: int = 0
#var draw_items: int = 0
#var draw_calls: int = 0
#var mem_texture: int = 0
#var mem_vertex: int = 0
#var rigids: int = 0
#var pairs: int = 0
#var islands: int = 0
#var audio_latency: int = 0
}

func _process(delta):
	if Input.is_action_just_pressed("dump"):
		print_data()


func print_data():
	print(JSON.print(dump_data()))


func dump_data() -> Dictionary:
	return {
		"fps":Performance.get_monitor(Performance.TIME_FPS),
		"process":Performance.get_monitor(Performance.TIME_PROCESS),
		"physics":Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS),
		"objects":Performance.get_monitor(Performance.OBJECT_COUNT),
		"resources":Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT),
		"nodes":Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
		"orphans":Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT),
		"render_items":Performance.get_monitor(Performance.RENDER_2D_ITEMS_IN_FRAME),
		"draw_calls":Performance.get_monitor(Performance.RENDER_2D_DRAW_CALLS_IN_FRAME),
		"mem_texture":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED),
		"mem_vertex":Performance.get_monitor(Performance.RENDER_VERTEX_MEM_USED),
		"rigids":Performance.get_monitor(Performance.PHYSICS_2D_ACTIVE_OBJECTS),
		"pairs":Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS),
		"islands":Performance.get_monitor(Performance.PHYSICS_2D_ISLAND_COUNT),
		"latency":Performance.get_monitor(Performance.AUDIO_OUTPUT_LATENCY),
	}
